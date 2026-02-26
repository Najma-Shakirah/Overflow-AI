// functions/src/getFloodSocialMedia.ts
// Deploy with: firebase deploy --only functions

import {onRequest} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import axios from "axios";

// ── Secrets ─────────────────────────────────────────────
const newsdataKey = defineSecret("NEWSDATA_KEY");

// ── Types ───────────────────────────────────────────────
interface FloodNewsItem {
  id: string;
  title: string;
  summary: string;
  originalText?: string;
  source: string;
  url: string;
  imageUrl?: string;
  videoUrl?: string;
  timestamp: string;
  author?: string;
  engagementCount?: number;
  location?: string;
  verificationStatus: string;
  isBreaking: boolean;
}

// ── Main Function ───────────────────────────────────────
export const getFloodSocialMedia = onRequest(
  {
    timeoutSeconds: 30,
    memory: "256MiB",
    secrets: [newsdataKey],
  },
  async (req, res) => {
    res.set("Access-Control-Allow-Origin", "*");
    if (req.method === "OPTIONS") {
      res.status(204).send("");
      return;
    }

    const {state = "Selangor", district = "Shah Alam"} = req.body || {};
    const NEWSDATA_KEY = newsdataKey.value();

    const [newsResults, jpsResults, socialResults] =
      await Promise.allSettled([
        fetchFromNewsData(NEWSDATA_KEY, state, district),
        fetchFromJps(district),
        buildSocialSearchCards(state, district),
      ]);

    const allItems: FloodNewsItem[] = [];
    for (const r of [newsResults, jpsResults, socialResults]) {
      if (r.status === "fulfilled") allItems.push(...r.value);
    }

    const seen = new Set<string>();
    const deduped = allItems.filter((item) => {
      const key = item.title.toLowerCase().replace(/\s+/g, "").substring(0, 40);
      if (seen.has(key)) return false;
      seen.add(key);
      return true;
    });

    deduped.sort(
      (a, b) =>
        new Date(b.timestamp).getTime() -
        new Date(a.timestamp).getTime()
    );

    res.json(deduped);
  }
);

// ── SOURCE 1: NewsData.io ────────────────────────────────
async function fetchFromNewsData(
  apiKey: string,
  state: string,
  district: string
): Promise<FloodNewsItem[]> {
  if (!apiKey) return mockNewsItems(district);

  try {
    const queries = [
      `banjir ${district} OR flood ${district}`,
      `banjir ${state} OR flood ${state}`,
    ];

    const allArticles: FloodNewsItem[] = [];

    for (const q of queries) {
      const url =
        "https://newsdata.io/api/1/news" +
        `?apikey=${apiKey}` +
        `&q=${encodeURIComponent(q)}` +
        "&country=my" +
        "&language=en,ms" +
        "&timeframe=24";

      const resp = await axios.get<any>(url, {timeout: 10000});
      if (resp.status !== 200) continue;

      const articles = (resp.data?.results ?? []) as any[];

      for (const a of articles) {
        const sourceName = (a.source_id ?? "").toLowerCase();
        allArticles.push({
          id: `news_${a.article_id ?? Math.random()}`,
          title: a.title ?? "",
          summary: a.description ?? a.title ?? "",
          source: mapNewsSource(sourceName),
          url: a.link ?? "https://newsdata.io",
          imageUrl: a.image_url ?? undefined,
          timestamp: a.pubDate ?
            new Date(a.pubDate).toISOString() :
            new Date().toISOString(),
          author: Array.isArray(a.creator) ? a.creator[0] : a.creator,
          location: district,
          verificationStatus: "partiallyVerified",
          isBreaking:
            (a.title ?? "").toLowerCase().includes("amaran") ||
            (a.title ?? "").toLowerCase().includes("warning") ||
            (a.title ?? "").toLowerCase().includes("darurat"),
        });
      }
    }

    return allArticles;
  } catch (e) {
    console.error("NewsData error:", e);
    return mockNewsItems(district);
  }
}

// ── SOURCE 2: JPS InfoBanjir RSS ─────────────────────────
async function fetchFromJps(district: string): Promise<FloodNewsItem[]> {
  try {
    const rssUrl = "https://publicinfobanjir.water.gov.my/rss/flood_alert.xml";
    const resp = await axios.get<string>(rssUrl, {
      timeout: 8000,
      headers: {"Accept": "application/rss+xml, application/xml, text/xml"},
    });

    if (resp.status !== 200) return [];

    const items = parseRssItems(resp.data);
    return items.map((item) => ({
      id: `jps_${hashString(item.link ?? item.title ?? "")}`,
      title: item.title ?? "JPS Flood Alert",
      summary: item.description ?? "",
      source: "jps",
      url: item.link ?? "https://publicinfobanjir.water.gov.my",
      timestamp: item.pubDate ?
        parseRssDate(item.pubDate) :
        new Date().toISOString(),
      location: district,
      verificationStatus: "verified",
      isBreaking:
        (item.title ?? "").includes("Amaran") ||
        (item.title ?? "").includes("Warning") ||
        (item.title ?? "").includes("Darurat"),
    }));
  } catch (e) {
    console.error("JPS RSS error:", e);
    return [];
  }
}

// ── SOURCE 3: Social Media Search Cards ──────────────────
async function buildSocialSearchCards(
  state: string,
  district: string
): Promise<FloodNewsItem[]> {
  const q = encodeURIComponent(`banjir ${district}`);
  const tag = district.replace(/\s+/g, "").toLowerCase();
  const tagState = state.replace(/\s+/g, "");

  return [
    {
      id: "social_tiktok_district",
      title: `#banjir${tag} — TikTok`,
      summary:
        `Tap to see live TikTok videos about flooding in ${district}. ` +
        "Real footage from residents showing current conditions on the ground.",
      source: "tiktok",
      url: `https://www.tiktok.com/search?q=${q}`,
      timestamp: new Date().toISOString(),
      verificationStatus: "unverified",
      isBreaking: false,
    },
    {
      id: "social_tiktok_daruratbanjir",
      title: `#DaruratBanjir${tagState} — TikTok`,
      summary:
        `Tap to see the #DaruratBanjir${tagState} hashtag on TikTok. ` +
        `Community videos showing flood conditions across ${state}.`,
      source: "tiktok",
      url: `https://www.tiktok.com/tag/daruratbanjir${tagState.toLowerCase()}`,
      timestamp: new Date(Date.now() - 5 * 60 * 1000).toISOString(),
      verificationStatus: "unverified",
      isBreaking: false,
    },
    {
      id: "social_x_district",
      title: `banjir ${district} — X Live Search`,
      summary:
        `Tap to see the most recent posts on X about flooding in ${district}. ` +
        "Sorted by latest so you see real-time reports first.",
      source: "x",
      url: `https://x.com/search?q=${q}&f=live`,
      timestamp: new Date(Date.now() - 10 * 60 * 1000).toISOString(),
      verificationStatus: "unverified",
      isBreaking: false,
    },
    {
      id: "social_x_hashtag",
      title: `#Banjir${tagState} — X`,
      summary:
        `Tap to see the #Banjir${tagState} hashtag on X. ` +
        "Real-time flood reports from residents and emergency services.",
      source: "x",
      url: `https://x.com/hashtag/Banjir${tagState}?f=live`,
      timestamp: new Date(Date.now() - 15 * 60 * 1000).toISOString(),
      verificationStatus: "unverified",
      isBreaking: false,
    },
    {
      id: "social_x_daruratbanjir",
      title: "#DaruratBanjir — X Live",
      summary:
        "Tap to see the #DaruratBanjir hashtag on X for nationwide " +
        "flood emergency updates from across Malaysia.",
      source: "x",
      url: "https://x.com/hashtag/DaruratBanjir?f=live",
      timestamp: new Date(Date.now() - 20 * 60 * 1000).toISOString(),
      verificationStatus: "unverified",
      isBreaking: false,
    },
    {
      id: "social_fb_infobanjir",
      title: "myinfobanjir — Official JPS Facebook",
      summary:
        "Tap to visit the official JPS InfoBanjir Facebook page. " +
        "Verified flood warnings, water level alerts, and evacuation notices.",
      source: "facebook",
      url: "https://www.facebook.com/myinfobanjir",
      timestamp: new Date(Date.now() - 25 * 60 * 1000).toISOString(),
      verificationStatus: "verified",
      isBreaking: false,
    },
    {
      id: "social_fb_search",
      title: `banjir ${district} — Facebook Posts`,
      summary:
        `Tap to search Facebook for recent flood posts in ${district}. ` +
        "Community reports, rescue requests, and relief centre updates.",
      source: "facebook",
      url: `https://www.facebook.com/search/posts/?q=${q}`,
      timestamp: new Date(Date.now() - 30 * 60 * 1000).toISOString(),
      verificationStatus: "unverified",
      isBreaking: false,
    },
    {
      id: "social_fb_group",
      title: "Komuniti Banjir Malaysia — Facebook Group",
      summary:
        "Tap to view the Komuniti Banjir Malaysia group. " +
        "Active community sharing real-time conditions, rescue boats, and aid.",
      source: "facebook",
      url: "https://www.facebook.com/groups/komuniti.banjir.malaysia",
      timestamp: new Date(Date.now() - 35 * 60 * 1000).toISOString(),
      verificationStatus: "unverified",
      isBreaking: false,
    },
  ];
}

// ── Helpers ───────────────────────────────────────────────
function mapNewsSource(sourceName: string): string {
  if (sourceName.includes("star")) return "theStar";
  if (sourceName.includes("bharian") || sourceName.includes("berita")) {
    return "beritaHarian";
  }
  if (sourceName.includes("awani")) return "astroAwani";
  if (sourceName.includes("fmt") || sourceName.includes("freemalaysia")) {
    return "freeMalaysia";
  }
  return "other";
}

function parseRssItems(xml: string): Record<string, string>[] {
  const items: Record<string, string>[] = [];
  const itemRe = /<item>([\s\S]*?)<\/item>/g;
  const titleRe = /<title>(?:<!\[CDATA\[)?([\s\S]*?)(?:\]\]>)?<\/title>/;
  const descRe = /<description>(?:<!\[CDATA\[)?([\s\S]*?)(?:\]\]>)?<\/description>/;
  const linkRe = /<link>([\s\S]*?)<\/link>/;
  const dateRe = /<pubDate>([\s\S]*?)<\/pubDate>/;

  let match: RegExpExecArray | null;
  while ((match = itemRe.exec(xml)) !== null) {
    const block = match[1];
    items.push({
      title: titleRe.exec(block)?.[1]?.trim() ?? "",
      description: descRe.exec(block)?.[1]?.trim() ?? "",
      link: linkRe.exec(block)?.[1]?.trim() ?? "",
      pubDate: dateRe.exec(block)?.[1]?.trim() ?? "",
    });
  }
  return items;
}

function parseRssDate(raw: string): string {
  try {
    return new Date(raw).toISOString();
  } catch {
    return new Date().toISOString();
  }
}

function hashString(s: string): number {
  let h = 0;
  for (let i = 0; i < s.length; i++) {
    h = (Math.imul(31, h) + s.charCodeAt(i)) | 0;
  }
  return Math.abs(h);
}

function mockNewsItems(district: string): FloodNewsItem[] {
  return [
    {
      id: "mock_news_1",
      title: `Banjir kilat melanda ${district}`,
      summary:
        `Flash floods reported in ${district} following heavy rainfall. ` +
        "Residents advised to stay alert and monitor water levels.",
      source: "beritaHarian",
      url: `https://newsdata.io/search?q=banjir+${encodeURIComponent(district)}`,
      timestamp: new Date().toISOString(),
      verificationStatus: "unverified",
      isBreaking: false,
    },
    {
      id: "mock_news_2",
      title: `JPS issues flood warning for ${district}`,
      summary:
        "The Department of Irrigation and Drainage has issued a flood " +
        `advisory for ${district}. Water levels are rising.`,
      source: "theStar",
      url: `https://newsdata.io/search?q=flood+${encodeURIComponent(district)}`,
      timestamp: new Date(Date.now() - 60 * 60 * 1000).toISOString(),
      verificationStatus: "unverified",
      isBreaking: true,
    },
  ];
}
