// lib/services/ai_service.dart
import 'dart:typed_data';
import 'package:firebase_ai/firebase_ai.dart';
// Need Color for riskColor getter
import 'package:flutter/material.dart';
import 'dart:convert';

class AIService {
  late final GenerativeModel _model;

  AIService() {
    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3-flash-preview',
    );
  }

  // ─────────────────────────────────────────────
  // FEATURE 1: Analyse a photo of a flooded area
  // ─────────────────────────────────────────────
  Future<FloodImageAnalysis> analyseFloodPhoto(Uint8List imageBytes) async {
    try {
      final prompt = Content.multi([
        InlineDataPart('image/jpeg', imageBytes),
        TextPart('''
          Analyse this image for flood conditions in Malaysia.
          Respond ONLY in this exact JSON format (no markdown, no extra text):
          {
            "floodDetected": true or false,
            "severity": "NONE" or "LOW" or "MODERATE" or "HIGH" or "CRITICAL",
            "waterLevel": "estimated water depth e.g. 0.5m or Not applicable",
            "hazards": ["list", "of", "visible", "hazards"],
            "immediateActions": ["action 1", "action 2", "action 3"],
            "safeToStay": true or false,
            "summary": "2-3 sentence plain English summary"
          }
        '''),
      ]);

      final response = await _model.generateContent([prompt]);
      final text = response.text ?? '';

      // Parse JSON response
      return FloodImageAnalysis.fromJson(text);
    } catch (e) {
      print('💥 analyseFloodPhoto error: $e');
      return FloodImageAnalysis.error();
    }
  }

  // ─────────────────────────────────────────────
  // FEATURE 2: AI-powered evacuation suggestions
  // ─────────────────────────────────────────────
  Future<EvacuationPlan> getEvacuationPlan({
    required String location,
    required String severity,
    required double rainfall,
    required double waterLevel,
  }) async {
    try {
      final prompt = Content.text('''
        Generate a flood evacuation plan for someone in $location, Malaysia.
        Current conditions:
        - Flood severity: $severity
        - Rainfall: ${rainfall}mm/hr
        - Water level: ${waterLevel}m
        
        Respond ONLY in this exact JSON format (no markdown, no extra text):
        {
          "urgency": "IMMEDIATE" or "SOON" or "MONITOR",
          "evacuateNow": true or false,
          "routes": [
            {"direction": "direction name", "landmark": "key landmark", "reason": "why this route"}
          ],
          "assemblyPoints": ["relief center or high ground name"],
          "whatToBring": ["item 1", "item 2", "item 3", "item 4", "item 5"],
          "callIfNeeded": "999",
          "timeframe": "how long they have e.g. Leave within 30 minutes",
          "summary": "2-3 sentence plain English summary"
        }
      ''');

      final response = await _model.generateContent([prompt]);
      return EvacuationPlan.fromJson(response.text ?? '');
    } catch (e) {
      print('💥 getEvacuationPlan error: $e');
      return EvacuationPlan.error();
    }
  }

  // ─────────────────────────────────────────────
  // FEATURE 3: Smart flood risk analysis
  // ─────────────────────────────────────────────
  Future<FloodRiskAnalysis> analyseFloodRisk({
    required String location,
    required double temperature,
    required double rainfall,
    required double humidity,
    required double windSpeed,
  }) async {
    try {
      final prompt = Content.text('''
        Analyse the flood risk for $location, Malaysia based on current weather:
        - Temperature: ${temperature.toStringAsFixed(1)}°C
        - Rainfall (last hour): ${rainfall}mm
        - Humidity: ${humidity.toInt()}%
        - Wind speed: ${windSpeed.toStringAsFixed(1)} m/s
        
        Consider Malaysia's monsoon patterns and typical flood-prone areas.
        Respond ONLY in this exact JSON format (no markdown, no extra text):
        {
          "riskLevel": "LOW" or "MODERATE" or "HIGH" or "CRITICAL",
          "riskScore": number from 0 to 100,
          "riskFactors": ["factor 1", "factor 2"],
          "forecast": "what is likely to happen in next few hours",
          "recommendations": ["recommendation 1", "recommendation 2", "recommendation 3"],
          "summary": "2 sentence plain English summary"
        }
      ''');

      final response = await _model.generateContent([prompt]);
      return FloodRiskAnalysis.fromJson(response.text ?? '');
    } catch (e) {
      print('💥 analyseFloodRisk error: $e');
      return FloodRiskAnalysis.error();
    }
  }

  // ─────────────────────────────────────────────
  // FEATURE 4: Auto-generate alert summary
  // ─────────────────────────────────────────────
  Future<String> generateAlertSummary({
    required String location,
    required String severity,
    required double rainfall,
    required double temperature,
    required double humidity,
  }) async {
    try {
      final prompt = Content.text('''
        Write a short, clear flood alert message for residents of $location, Malaysia.
        Weather data:
        - Severity: $severity
        - Rainfall: ${rainfall}mm/hr
        - Temperature: ${temperature.toStringAsFixed(1)}°C
        - Humidity: ${humidity.toInt()}%
        
        Rules:
        - Maximum 2 sentences
        - Plain English, no jargon
        - Include one specific safety action
        - Sound like an official government alert
        - Do NOT use markdown or bullet points
      ''');

      final response = await _model.generateContent([prompt]);
      return response.text?.trim() ??
          'Flood conditions detected in your area. Please stay alert and follow official guidance.';
    } catch (e) {
      print('💥 generateAlertSummary error: $e');
      return 'Unable to generate alert summary at this time.';
    }
  }
}

// ─────────────────────────────────────────────
// Data models for AI responses
// ─────────────────────────────────────────────

class FloodImageAnalysis {
  final bool floodDetected;
  final String severity;
  final String waterLevel;
  final List<String> hazards;
  final List<String> immediateActions;
  final bool safeToStay;
  final String summary;
  final bool hasError;

  FloodImageAnalysis({
    required this.floodDetected,
    required this.severity,
    required this.waterLevel,
    required this.hazards,
    required this.immediateActions,
    required this.safeToStay,
    required this.summary,
    this.hasError = false,
  });

  factory FloodImageAnalysis.fromJson(String raw) {
    try {
      // Strip any markdown code fences if present
      final clean = raw
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final json = jsonDecode(clean);
      return FloodImageAnalysis(
        floodDetected: json['floodDetected'] ?? false,
        severity: json['severity'] ?? 'NONE',
        waterLevel: json['waterLevel'] ?? 'N/A',
        hazards: List<String>.from(json['hazards'] ?? []),
        immediateActions: List<String>.from(json['immediateActions'] ?? []),
        safeToStay: json['safeToStay'] ?? true,
        summary: json['summary'] ?? '',
      );
    } catch (e) {
      print('Parse error FloodImageAnalysis: $e\nRaw: $raw');
      return FloodImageAnalysis.error();
    }
  }

  factory FloodImageAnalysis.error() => FloodImageAnalysis(
        floodDetected: false,
        severity: 'UNKNOWN',
        waterLevel: 'N/A',
        hazards: [],
        immediateActions: ['Could not analyse image. Please try again.'],
        safeToStay: true,
        summary: 'Analysis failed. Please try again.',
        hasError: true,
      );
}

class EvacuationPlan {
  final String urgency;
  final bool evacuateNow;
  final List<Map<String, String>> routes;
  final List<String> assemblyPoints;
  final List<String> whatToBring;
  final String callIfNeeded;
  final String timeframe;
  final String summary;
  final bool hasError;

  EvacuationPlan({
    required this.urgency,
    required this.evacuateNow,
    required this.routes,
    required this.assemblyPoints,
    required this.whatToBring,
    required this.callIfNeeded,
    required this.timeframe,
    required this.summary,
    this.hasError = false,
  });

  factory EvacuationPlan.fromJson(String raw) {
    try {
      final clean = raw
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final json = jsonDecode(clean);
      return EvacuationPlan(
        urgency: json['urgency'] ?? 'MONITOR',
        evacuateNow: json['evacuateNow'] ?? false,
        routes: (json['routes'] as List? ?? [])
            .map((r) => Map<String, String>.from(r))
            .toList(),
        assemblyPoints: List<String>.from(json['assemblyPoints'] ?? []),
        whatToBring: List<String>.from(json['whatToBring'] ?? []),
        callIfNeeded: json['callIfNeeded'] ?? '999',
        timeframe: json['timeframe'] ?? '',
        summary: json['summary'] ?? '',
      );
    } catch (e) {
      print('Parse error EvacuationPlan: $e\nRaw: $raw');
      return EvacuationPlan.error();
    }
  }

  factory EvacuationPlan.error() => EvacuationPlan(
        urgency: 'MONITOR',
        evacuateNow: false,
        routes: [],
        assemblyPoints: [],
        whatToBring: [],
        callIfNeeded: '999',
        timeframe: 'Unknown',
        summary: 'Could not generate evacuation plan. Call 999 if in danger.',
        hasError: true,
      );
}

class FloodRiskAnalysis {
  final String riskLevel;
  final int riskScore;
  final List<String> riskFactors;
  final String forecast;
  final List<String> recommendations;
  final String summary;
  final bool hasError;

  FloodRiskAnalysis({
    required this.riskLevel,
    required this.riskScore,
    required this.riskFactors,
    required this.forecast,
    required this.recommendations,
    required this.summary,
    this.hasError = false,
  });

  factory FloodRiskAnalysis.fromJson(String raw) {
    try {
      final clean = raw
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final json = jsonDecode(clean);
      return FloodRiskAnalysis(
        riskLevel: json['riskLevel'] ?? 'LOW',
        riskScore: (json['riskScore'] as num?)?.toInt() ?? 0,
        riskFactors: List<String>.from(json['riskFactors'] ?? []),
        forecast: json['forecast'] ?? '',
        recommendations: List<String>.from(json['recommendations'] ?? []),
        summary: json['summary'] ?? '',
      );
    } catch (e) {
      print('Parse error FloodRiskAnalysis: $e\nRaw: $raw');
      return FloodRiskAnalysis.error();
    }
  }

  factory FloodRiskAnalysis.error() => FloodRiskAnalysis(
        riskLevel: 'UNKNOWN',
        riskScore: 0,
        riskFactors: [],
        forecast: 'Unable to analyse risk at this time.',
        recommendations: ['Stay alert', 'Monitor local news', 'Call 999 if in danger'],
        summary: 'Risk analysis unavailable. Stay cautious.',
        hasError: true,
      );

  Color get riskColor {
    switch (riskLevel) {
      case 'CRITICAL': return const Color(0xFFD32F2F);
      case 'HIGH': return const Color(0xFFF57C00);
      case 'MODERATE': return const Color(0xFFFBC02D);
      default: return const Color(0xFF388E3C);
    }
  }
}
