
import { GoogleGenAI } from "@google/genai";
import { Platform, MonetizationStatus, AppealTone } from "../types";

export async function generateAppealDraft(params: {
  platform: Platform;
  status: MonetizationStatus;
  violation: string;
  notes: string;
  fixes: string[];
  evidence: string[];
  tone: AppealTone;
}) {
  const ai = new GoogleGenAI({ apiKey: process.env.API_KEY });
  const model = 'gemini-3-flash-preview';

  const prompt = `
    Act as a World-Class Monetization Compliance Lawyer and Policy Expert.
    
    CONTEXT:
    A digital asset has been flagged for a violation on ${params.platform}.
    Status: ${params.status}
    Violation: ${params.violation}
    Specific Situation: ${params.notes}
    Corrective Actions Taken: ${params.fixes.join(', ')}
    Evidence Provided: ${params.evidence.join(', ')}
    Target Tone: ${params.tone}

    STRICT GUIDELINES:
    1. NEVER admit guilt falsely. Focus on alignment with platform goals.
    2. USE professional, platform-specific terminology (e.g., "Transformative value" for YT/FB, "Policy alignment" for TikTok).
    3. BE RESPECTFUL. No threats or accusations of "broken systems."
    4. STRUCTURE: Title, Salutation, Issue Description, Fixes Taken, Evidence Summary, Compliance Commitment, Reinstatement Request.
    5. OPTIONAL: Provide a "Short" and "Long" version.

    OUTPUT FORMAT (Markdown):
    ### [Title]
    [Body]
    
    ### Action Summary
    [Bullet points of fixes]
    
    ### Policy Alignment Note
    [Brief technical explanation of why this account now meets standards]

    ### Risk Score (1-10)
    [Score based on your expert analysis]
  `;

  try {
    const response = await ai.models.generateContent({
      model: model,
      contents: prompt,
      config: {
        temperature: 0.6,
        topP: 0.9,
      }
    });
    return response.text;
  } catch (error) {
    console.error("Appeal AI Error:", error);
    throw new Error("AI Terminal failed to synchronize draft parameters.");
  }
}

export async function getPolicyAnalysis(violation: string, platform: Platform) {
  const ai = new GoogleGenAI({ apiKey: process.env.API_KEY });
  const model = 'gemini-3-flash-preview';

  const prompt = `
    Explain the following monetization violation policy in simple but professional terms:
    Violation: ${violation}
    Platform: ${platform}
    
    Include:
    1. What likely triggered the AI flag (common patterns).
    2. High-level content improvement strategy.
    3. Three specific keywords to use in an appeal.
  `;

  try {
    const response = await ai.models.generateContent({
      model: model,
      contents: prompt,
    });
    return response.text;
  } catch (error) {
    return "Policy intelligence unavailable.";
  }
}
