
import { GoogleGenAI } from "@google/genai";
import { BusinessStats, Project } from "../types";

export async function getBusinessInsights(stats: BusinessStats, projects: Project[]) {
  const ai = new GoogleGenAI({ apiKey: process.env.API_KEY });
  const model = 'gemini-3-flash-preview';
  
  const roi = stats.totalInvestmentMMK > 0 ? ((stats.totalProfitMMK / stats.totalInvestmentMMK) * 100).toFixed(1) : 0;

  const prompt = `
    Act as a high-level digital business consultant and financial analyst for a Myanmar-based agency. 
    Analyze the following performance data (Values in Myanmar Kyats - MMK):
    
    Local Market Financial Stats (MMK):
    - Total Revenue (ရောင်းရငွေ): ${stats.totalRevenueMMK.toLocaleString()} Ks
    - Total Investment (ဝယ်ဈေး/ကုန်ကျစရိတ်): ${stats.totalInvestmentMMK.toLocaleString()} Ks
    - Net Profit (အသားတင်အမြတ်): ${stats.totalProfitMMK.toLocaleString()} Ks
    - ROI (Return on Investment): ${roi}%
    
    Overall Global Stats (USD context):
    - Gross Revenue: $${stats.totalRevenue}
    - Service Fee Revenue: $${stats.serviceFeeRevenue}
    
    Operational Data:
    - Active Projects: ${stats.activeProjects}
    - Total Clients: ${stats.totalClients}
    
    Please provide:
    1. A brief executive summary of the business health focused on profitability in MMK.
    2. Analyze the 'Buy vs Sell' efficiency (e.g. if the agency buys an account for 3.4 Lakh and sells for 6 Lakh).
    3. Three actionable strategies to increase the local market profit margins.
    4. A "Growth Score" from 1-10 based on the MMK ROI.
    
    Format the response in clean Markdown.
  `;

  try {
    const response = await ai.models.generateContent({
      model: model,
      contents: prompt,
      config: {
        temperature: 0.7,
        topP: 0.95,
      }
    });
    return response.text;
  } catch (error) {
    console.error("Gemini API Error:", error);
    throw new Error("Failed to fetch financial insights.");
  }
}

export async function getDetailedPolicyAnalysis(platform: string, violation: string, details: string) {
  const ai = new GoogleGenAI({ apiKey: process.env.API_KEY });
  const model = 'gemini-3-flash-preview';

  const prompt = `
    Act as an Elite Social Media Monetization Compliance Officer.
    
    AUDIT TARGET:
    - Platform: ${platform}
    - Reported Violation: ${violation}
    - Situation Briefing: ${details}

    TASK: Provide an industrial-grade policy analysis report.
    
    REQUIRED SECTIONS:
    1. ALGORITHMIC TRIGGER ANALYSIS: Explain technically why the ${platform} automated systems likely flagged this asset (e.g., hash collisions, metadata velocity, or visual patterns).
    2. RECOVERY PROTOCOL: 3 immediate technical steps to take in the account settings or content library to resolve the "Red/Yellow" status.
    3. GROWTH PIVOT: Strategy to modify the content style to ensure 100% compliance moving forward while maintaining virality.
    4. AD-FRIENDLY SCORE: Rate the safety of this content niche from 1-10 for advertisers.

    Format the response in clean, professional Markdown with a focus on actionable intelligence.
  `;

  try {
    const response = await ai.models.generateContent({
      model: model,
      contents: prompt,
      config: {
        temperature: 0.5,
        topP: 0.9,
      }
    });
    return response.text;
  } catch (error) {
    console.error("Policy AI Error:", error);
    throw new Error("AI Mainframe failed to sync policy parameters.");
  }
}

export async function getAiAssistantResponse(userMessage: string, customPrompt: string) {
  const ai = new GoogleGenAI({ apiKey: process.env.API_KEY });
  const model = 'gemini-3-flash-preview';

  const defaultPrompt = `You are a helpful AI Assistant for One Stars Digital agency in Myanmar. 
  Your primary goal is to explain services, provide general guidance on social media monetization, and help with FAQ.
  
  RULES:
  - You CANNOT see user accounts, payments, or payout statuses.
  - If asked about "money", "payment", "payout not received", "verification status", or "account issues", tell the user: "ကိုယ်ရေးကိုယ်တာ account နှင့် ပိုက်ဆံဆိုင်ရာ ကိစ္စများကို AI မှ မကြည့်နိုင်ပါ။ 'Human Support' tab သို့သွား၍ Support Team ကို ဆက်သွယ်ပေးပါ။"
  - Be professional and helpful.
  - Mix English and Myanmar naturally.
  - Do not promise specific dates or earnings.`;

  const prompt = `
    System Instruction: ${customPrompt || defaultPrompt}
    User Query: ${userMessage}
    AI Response:
  `;

  try {
    const response = await ai.models.generateContent({
      model: model,
      contents: prompt,
      config: {
        temperature: 0.8,
        topP: 0.9,
      }
    });
    return response.text;
  } catch (error) {
    console.error("Gemini Assistant Error:", error);
    return "Link error. Please try again or contact human support.";
  }
}
