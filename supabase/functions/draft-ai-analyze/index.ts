import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const ADMIN_EMAIL = (Deno.env.get("ADMIN_EMAIL") || "pcygnus2112@gmail.com").toLowerCase();
const OPENAI_MODEL = Deno.env.get("OPENAI_MODEL") || "gpt-4o-mini";

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

async function requireAdmin(req: Request) {
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const auth = req.headers.get("Authorization") || "";
  if (!supabaseUrl || !anonKey || !auth) throw new Error("Missing Supabase auth configuration.");

  const res = await fetch(`${supabaseUrl}/auth/v1/user`, {
    headers: {
      apikey: anonKey,
      Authorization: auth,
    },
  });
  if (!res.ok) throw new Error("Not authenticated.");
  const user = await res.json();
  const email = String(user.email || "").toLowerCase();
  if (email !== ADMIN_EMAIL) throw new Error("Only the site admin can run draft AI analysis.");
  return user;
}

const analysisSchema = {
  type: "object",
  additionalProperties: false,
  required: ["dialogue", "entities", "layers", "literaryFunction", "conversionTargets", "uncertainties"],
  properties: {
    dialogue: {
      type: "array",
      items: {
        type: "object",
        additionalProperties: false,
        required: ["quote", "speakerGuess", "addressedToGuess", "confidence", "evidence", "emotionalTone", "subtext", "sceneFunction"],
        properties: {
          quote: { type: "string" },
          speakerGuess: { type: "string" },
          addressedToGuess: { type: "string" },
          confidence: { type: "number" },
          evidence: { type: "string" },
          emotionalTone: { type: "string" },
          subtext: { type: "string" },
          sceneFunction: { type: "string" },
        },
      },
    },
    entities: {
      type: "array",
      items: {
        type: "object",
        additionalProperties: false,
        required: ["name", "type", "aliases", "confidence", "firstMentionQuote", "description", "relationships", "suggestedCodexCategory"],
        properties: {
          name: { type: "string" },
          type: { type: "string" },
          aliases: { type: "array", items: { type: "string" } },
          confidence: { type: "number" },
          firstMentionQuote: { type: "string" },
          description: { type: "string" },
          relationships: { type: "array", items: { type: "string" } },
          suggestedCodexCategory: { type: "string" },
        },
      },
    },
    layers: {
      type: "object",
      additionalProperties: false,
      required: ["themes", "motifs", "narrativeDevices", "locations", "researchSubjects", "timelineClues", "pov", "tone", "chapterFit", "protoevangeliumResonance", "confidence"],
      properties: {
        themes: { type: "array", items: { type: "string" } },
        motifs: { type: "array", items: { type: "string" } },
        narrativeDevices: { type: "array", items: { type: "string" } },
        locations: { type: "array", items: { type: "string" } },
        researchSubjects: { type: "array", items: { type: "string" } },
        timelineClues: { type: "array", items: { type: "string" } },
        pov: { type: "string" },
        tone: { type: "string" },
        chapterFit: { type: "string" },
        protoevangeliumResonance: { type: "string" },
        confidence: { type: "number" },
      },
    },
    literaryFunction: {
      type: "object",
      additionalProperties: false,
      required: ["summary", "narrativePurpose", "stakes", "tension", "continuityNotes", "confidence"],
      properties: {
        summary: { type: "string" },
        narrativePurpose: { type: "string" },
        stakes: { type: "string" },
        tension: { type: "string" },
        continuityNotes: { type: "string" },
        confidence: { type: "number" },
      },
    },
    conversionTargets: {
      type: "array",
      items: {
        type: "object",
        additionalProperties: false,
        required: ["target", "rationale", "confidence"],
        properties: {
          target: { type: "string" },
          rationale: { type: "string" },
          confidence: { type: "number" },
        },
      },
    },
    uncertainties: { type: "array", items: { type: "string" } },
  },
};

function outputText(data: any) {
  if (typeof data.output_text === "string") return data.output_text;
  const chunks: string[] = [];
  for (const item of data.output || []) {
    for (const content of item.content || []) {
      if (content.type === "output_text" && content.text) chunks.push(content.text);
    }
  }
  return chunks.join("\n");
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "Method not allowed." }, 405);

  try {
    await requireAdmin(req);
    const apiKey = Deno.env.get("OPENAI_API_KEY");
    if (!apiKey) throw new Error("OPENAI_API_KEY is not configured.");
    const payload = await req.json();

    const response = await fetch("https://api.openai.com/v1/responses", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: OPENAI_MODEL,
        input: [
          {
            role: "system",
            content:
              "You are a literary analysis engine for a nonlinear novel draft inbox. Return only schema-valid JSON. Be conservative: use confidence scores, preserve uncertainty, and never claim canon certainty.",
          },
          {
            role: "user",
            content:
              "Analyze this draft fragment for dialogue speakers, entities, literary layers, and conversion targets. Existing project context is included for disambiguation.\n\n" +
              JSON.stringify(payload),
          },
        ],
        text: {
          format: {
            type: "json_schema",
            name: "draft_fragment_analysis",
            schema: analysisSchema,
            strict: true,
          },
        },
      }),
    });

    if (!response.ok) {
      const message = await response.text();
      throw new Error(`OpenAI request failed: ${message}`);
    }
    const data = await response.json();
    const text = outputText(data);
    const report = JSON.parse(text);
    return json({ report, model: OPENAI_MODEL });
  } catch (err) {
    return json({ error: err instanceof Error ? err.message : String(err) }, 400);
  }
});
