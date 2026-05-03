const state = {
  money: 500,
  xp: 0,
  level: 1,
  reputation: "Emerging Builder",
  publicFund: 0,
  currentDistrict: "Home Base",
  currentWaypoint: "client_district",
  nextBestMove: "Go to 💼 Client District.",
  learningBoost: 1,
  inventory: ["Prompt Kit", "Pitch Notes", "Trust Script"],
  skills: {
    prompting: { label: "AI Prompting", level: 1, mastery: 34 },
    communication: { label: "Communication", level: 1, mastery: 32 },
    research: { label: "Research", level: 1, mastery: 36 },
    design: { label: "Design", level: 1, mastery: 24 },
    webDev: { label: "Web Development", level: 1, mastery: 20 },
    business: { label: "Business Strategy", level: 1, mastery: 29 }
  },
  contractsWon: 0,
  communityImpact: 0,
  claimedAssets: [],
  completedMissions: [],
  unlockedRfps: [],
  discoveredDistricts: [],
  discoveredNpcs: [],
  tutorial: {
    step: 0,
    progress: {
      moved: false,
      reachedClientDistrict: false,
      talkedToYouthDirector: false,
      startedPitch: false,
      wonFirstContract: false,
      reachedTrainingCenter: false,
      returnedHome: false
    }
  },
  activeMission: {
    missionId: "reflection_planning",
    districtId: "home_base",
    title: "Board Coach Guidance",
    objective: "Walk to the Client District to claim your first opportunity.",
    reward: "First contract unlock + 10 XP",
    rewardMoney: 0,
    rewardXP: 10,
    rewardReputation: 0,
    publicFund: 0,
    skill: "Strategy",
    sourceType: "npc",
    sourceName: "Board Coach",
    actionLabel: "Start Mission"
  },
  feed: [
    { title: "Board Coach", body: "Welcome to AI Workforce City. Use Arrow Keys or WASD to move, then press E to interact." }
  ]
};

const initialState = JSON.parse(JSON.stringify(state));

const tutorialQuest = {
  title: "First Contract",
  reward: "$500 + 25 XP",
  steps: [
    { id: "moved", label: "Walk to Client District" },
    { id: "talkedToYouthDirector", label: "Talk to Youth Program Director" },
    { id: "startedPitch", label: "Choose the best pitch" },
    { id: "wonFirstContract", label: "Win contract" },
    { id: "reachedTrainingCenter", label: "Go to Training Center" },
    { id: "returnedHome", label: "Return to Home Base to reflect" }
  ]
};

const TAX_RATE = 0.1;
const PUBLIC_FUND_RFP_THRESHOLD = 50;
const SKILL_TRAINING_MAP = {
  prompting: "Go to Training Center -> Train AI Prompting.",
  communication: "Go to Training Center -> Train Communication.",
  research: "Go to Training Center -> Train Research.",
  design: "Go to Training Center -> Train Design.",
  webDev: "Go to Training Center -> Train Web Development.",
  business: "Go to Training Center -> Train Business Strategy."
};

const locationTargets = [
  { id: "home_base", label: "Home Base" },
  { id: "client_district", label: "Client District" },
  { id: "training_center", label: "Training Center" },
  { id: "tool_market", label: "Tool Market" },
  { id: "city_hall", label: "City Hall" },
  { id: "demo_arena", label: "Demo Arena" }
];

const LOCATION_META = {
  home_base: { icon: "🏠", label: "Home Base" },
  client_district: { icon: "💼", label: "Client District" },
  training_center: { icon: "🧠", label: "Training Center" },
  tool_market: { icon: "🛠", label: "Tool Market" },
  city_hall: { icon: "🏛", label: "City Hall" },
  networking_plaza: { icon: "🤝", label: "Networking Hub" },
  opportunity_plaza: { icon: "📋", label: "Opportunity Plaza" },
  innovation_lab: { icon: "⚙️", label: "Innovation Lab" },
  demo_arena: { icon: "🏆", label: "Demo Arena" },
  market_street: { icon: "📈", label: "Market Street" }
};

const MISSION_LEARNING_OUTCOMES = {
  reflection_planning: [
    "Clear goals reduce overwhelm.",
    "A waypoint helps you act faster.",
    "Planning makes the next mission easier."
  ],
  skill_training_intro: [
    "Training raises your win rate.",
    "Prompt quality shapes output quality.",
    "Better research improves client fit."
  ],
  youth_forward_gr: [
    "The real problem matters more than the surface request.",
    "Trust drives enrollment decisions.",
    "Strong communication increases success rate."
  ],
  tool_market_intro: [
    "The right tool supports the mission.",
    "Budget choices change delivery quality.",
    "Tool fit beats tool hype."
  ],
  public_fund_intro: [
    "Public systems can unlock opportunity.",
    "Small wins can grow civic funding.",
    "Taxes can create future missions."
  ],
  home_reflection_loop: [
    "Reflection turns wins into strategy.",
    "One clear next step beats vague ambition.",
    "Learning compounds across missions."
  ],
  parent_trust_sprint: [
    "Clear trust signals improve response.",
    "Shorter messaging can convert better.",
    "Families need simple next steps."
  ],
  city_hall_data_story: [
    "Evidence makes impact visible.",
    "Data needs a clear story.",
    "Decision-makers fund what they can understand."
  ],
  innovation_lab_autoflow: [
    "Reusable workflows scale quality.",
    "Human review still matters.",
    "Good systems save time without losing judgment."
  ],
  mentor_network_boost: [
    "Specific questions produce better feedback.",
    "Mentor advice is only useful when applied.",
    "Positioning can change a pitch outcome."
  ],
  city_rfp_unlock: [
    "Readiness matters before scale.",
    "A scoped RFP is easier to win well.",
    "Public value should guide contract selection."
  ],
  community_outreach_rfp: [
    "Public-facing work needs trust and proof.",
    "Clear rollout plans beat vague promises.",
    "Higher-value contracts demand stronger strategy."
  ]
};

const MISSION_SKILL_IMPROVEMENTS = {
  reflection_planning: "Strategy +1",
  skill_training_intro: "AI Prompting +1",
  youth_forward_gr: "Communication +1",
  tool_market_intro: "Production +1",
  public_fund_intro: "Systems Thinking +1",
  home_reflection_loop: "Strategy +1",
  parent_trust_sprint: "Communication +1",
  city_hall_data_story: "Research +1",
  innovation_lab_autoflow: "Web Development +1",
  mentor_network_boost: "Communication +1",
  city_rfp_unlock: "Business Strategy +1",
  community_outreach_rfp: "Communication +1"
};

const demoState = {
  active: false,
  timers: [],
  stepIndex: -1,
  steps: []
};

const missions = {
  reflection_planning: {
    title: "Home Base / Student Hub",
    objective: "Set your plan, then head to Client District for your first contract.",
    reward: "10 XP + Route Guidance",
    rewardMoney: 0,
    rewardXP: 10,
    rewardReputation: 0,
    publicFund: 0,
    skill: "Strategy",
    sourceType: "district",
    sourceName: "Home Base",
    actionLabel: "Reflect and Plan"
  },
  skill_training_intro: {
    title: "Training Center",
    objective: "Complete a skill acquisition session that improves prompting and research before your next judged task.",
    reward: "20 XP + Skill Upgrade",
    rewardMoney: 0,
    rewardXP: 20,
    rewardReputation: 0,
    publicFund: 0,
    skill: "AI Prompting + Research",
    sourceType: "district",
    sourceName: "Training Center",
    actionLabel: "Upgrade Skills"
  },
  youth_forward_gr: {
    title: "Youth Forward GR",
    objective: "Build a parent-friendly enrollment solution for a real youth program.",
    reward: "$500 + 25 XP + 10 Reputation",
    rewardMoney: 500,
    rewardXP: 25,
    rewardReputation: 10,
    publicFund: 50,
    skill: "Communication + AI Prompting",
    sourceType: "npc",
    sourceName: "Youth Program Director",
    actionLabel: "Start Pitch Challenge"
  },
  tool_market_intro: {
    title: "Tool Stack Upgrade",
    objective: "Choose the right production tool for the opportunity model so your next output is stronger and faster to ship.",
    reward: "Asset Unlock + Workflow Boost",
    rewardMoney: -120,
    rewardXP: 0,
    rewardReputation: 0,
    publicFund: 0,
    skill: "Strategy + Production",
    sourceType: "district",
    sourceName: "Tool Market",
    actionLabel: "Buy Tools"
  },
  public_fund_intro: {
    title: "Taxes and Public Fund",
    objective: "See how contract taxes build the public fund and unlock larger city-backed RFP opportunities.",
    reward: "Public Fund Insight",
    rewardMoney: 0,
    rewardXP: 12,
    rewardReputation: 0,
    publicFund: 0,
    skill: "Systems Thinking",
    sourceType: "district",
    sourceName: "City Hall",
    actionLabel: "Review Fund"
  },
  networking_intro: {
    title: "Networking Event",
    objective: "Build connections with mentors and partners that strengthen your next proposal and open new opportunity leads.",
    reward: "Reputation + Contacts",
    rewardMoney: 0,
    rewardXP: 14,
    rewardReputation: 6,
    publicFund: 0,
    skill: "Communication",
    sourceType: "district",
    sourceName: "Networking Hub",
    actionLabel: "Meet Partners"
  },
  opportunity_board_intro: {
    title: "Opportunity Model Board",
    objective: "Review live opportunity records, compare goals, constraints, and rewards, then claim the strongest fit.",
    reward: "Contract Unlock",
    rewardMoney: 0,
    rewardXP: 12,
    rewardReputation: 0,
    publicFund: 0,
    skill: "Research + Strategy",
    sourceType: "district",
    sourceName: "Opportunity Plaza",
    actionLabel: "Claim Opportunity"
  },
  innovation_lab_intro: {
    title: "Prompt and Output Judge Lab",
    objective: "Prototype a stronger AI workflow and improve how your prompts and outputs score against the judge criteria.",
    reward: "Innovation Badge + 18 XP",
    rewardMoney: 0,
    rewardXP: 18,
    rewardReputation: 4,
    publicFund: 0,
    skill: "Prompting + Strategy",
    sourceType: "district",
    sourceName: "Innovation Lab",
    actionLabel: "Prototype Solution"
  },
  boss_pitch_battle: {
    title: "Demo Arena",
    objective: "Defeat the NPC Agency rival and win a bigger contract.",
    reward: "$900 + 40 XP + 18 Reputation",
    rewardMoney: 900,
    rewardXP: 40,
    rewardReputation: 18,
    publicFund: 80,
    skill: "Pitching + Strategy",
    sourceType: "npc",
    sourceName: "NPC Agency Rival",
    actionLabel: "Enter Boss Pitch"
  },
  market_street_intro: {
    title: "Newsfeed and Market Signals",
    objective: "Scan live demand signals and use the city newsfeed to anticipate what opportunities are opening next.",
    reward: "Trend Intel",
    rewardMoney: 0,
    rewardXP: 10,
    rewardReputation: 0,
    publicFund: 0,
    skill: "Research",
    sourceType: "district",
    sourceName: "Market Street",
    actionLabel: "Scan Market"
  },
  parent_trust_sprint: {
    title: "Parent Trust Sprint",
    objective: "Build a trust-first communication sequence that explains benefits, audience fit, and clear next steps for families.",
    reward: "$650 + 30 XP + 12 Reputation",
    rewardMoney: 650,
    rewardXP: 30,
    rewardReputation: 12,
    publicFund: 60,
    skill: "Communication + Design",
    sourceType: "district",
    sourceName: "Client District",
    actionLabel: "Start Outreach Sprint",
    location: "Client District",
    required: "Communication Level 1 + Prompting Level 1",
    status: "Available"
  },
  city_hall_data_story: {
    title: "Public Fund Impact Story",
    objective: "Turn taxes, contract outcomes, and civic metrics into a clear story that shows how the public fund creates opportunity.",
    reward: "$420 + 22 XP",
    rewardMoney: 420,
    rewardXP: 22,
    rewardReputation: 6,
    publicFund: 35,
    skill: "Research + Business Strategy",
    sourceType: "district",
    sourceName: "City Hall",
    actionLabel: "Build Data Story",
    location: "City Hall",
    required: "Research Level 1 + Business Strategy Level 1",
    status: "Available"
  },
  innovation_lab_autoflow: {
    title: "Prompt Judge Autoflow",
    objective: "Prototype an AI-assisted workflow that improves prompt quality, output quality, and delivery speed.",
    reward: "$780 + 34 XP",
    rewardMoney: 780,
    rewardXP: 34,
    rewardReputation: 10,
    publicFund: 40,
    skill: "AI Prompting + Web Development",
    sourceType: "district",
    sourceName: "Innovation Lab",
    actionLabel: "Prototype Autoflow",
    location: "Innovation Lab",
    required: "AI Prompting Level 1 + Web Development Level 1",
    status: "Available"
  },
  mentor_network_boost: {
    title: "Mentor Network Boost",
    objective: "Use a networking event to collect mentor feedback, compare strategies, and improve your next contract pitch.",
    reward: "$300 + 18 XP + 8 Reputation",
    rewardMoney: 300,
    rewardXP: 18,
    rewardReputation: 8,
    publicFund: 20,
    skill: "Communication + Strategy",
    sourceType: "district",
    sourceName: "Networking Hub",
    actionLabel: "Meet Mentor",
    location: "Networking Hub",
    required: "Communication Level 1",
    status: "Available"
  },
  city_rfp_unlock: {
    title: "City RFP Unlock",
    objective: "Use the public fund and opportunity board to unlock a new city RFP with clearer scope, reward, and constraints.",
    reward: "$850 + 36 XP + 12 Reputation",
    rewardMoney: 850,
    rewardXP: 36,
    rewardReputation: 12,
    publicFund: 0,
    skill: "Research + Business Strategy",
    sourceType: "district",
    sourceName: "Opportunity Plaza",
    actionLabel: "Unlock RFP",
    location: "Opportunity Plaza",
    required: "Research Level 2 + Public Fund Insight",
    status: "Locked Until Public Fund Grows"
  },
  home_reflection_loop: {
    title: "Reflect and Reinvest",
    objective: "Return home, answer strategy questions, and choose how to reinvest money, time, and skills before the next day loop.",
    reward: "12 XP + Planning Bonus",
    rewardMoney: 0,
    rewardXP: 12,
    rewardReputation: 0,
    publicFund: 0,
    skill: "Strategy",
    sourceType: "district",
    sourceName: "Home Base",
    actionLabel: "Reflect and Reinvest",
    location: "Home Base",
    required: "One completed contract",
    status: "Available"
  },
  community_outreach_rfp: {
    title: "Community Outreach RFP",
    objective: "Use public-fund-backed outreach support to launch a stronger city-wide enrollment campaign.",
    reward: "$1,200 + 40 XP + 15 Reputation",
    rewardMoney: 1200,
    rewardXP: 40,
    rewardReputation: 15,
    publicFund: 0,
    skill: "Communication + Research",
    sourceType: "district",
    sourceName: "Opportunity Plaza",
    actionLabel: "Review RFP",
    location: "Opportunity Plaza",
    required: "Communication Level 2 + Research Level 1",
    status: "Locked Until Public Fund Reaches $50"
  }
};

Object.entries(missions).forEach(([id, mission]) => {
  Object.assign(mission, {
    id,
    organization: mission.organization ?? mission.title,
    fundingSource: mission.fundingSource ?? "TRIO opportunity pipeline",
    totalBudget: mission.totalBudget ?? 25000,
    remainingBudget: mission.remainingBudget ?? Math.max(2500, Math.round((mission.rewardMoney || 0) * 12)),
    deadlineCycles: mission.deadlineCycles ?? 12,
    needType: mission.needType ?? "Workforce readiness solution",
    reasonWhy: mission.reasonWhy ?? mission.objective,
    desiredOutcome: mission.desiredOutcome ?? mission.objective,
    constraints: mission.constraints ?? ["Low budget", "Clear next step", "Audience fit"],
    priority: mission.priority ?? "Medium",
    hiddenFactor: mission.hiddenFactor ?? "The strongest solution must solve the real human barrier, not just ship an output.",
    npcCompetition: mission.npcCompetition ?? "Low",
    requiredSkills: mission.requiredSkills ?? [],
    requiredTools: mission.requiredTools ?? [],
    reputationReward: mission.reputationReward ?? mission.rewardReputation ?? 0,
    impactReward: mission.impactReward ?? 6,
    publicFundBonus: mission.publicFundBonus ?? mission.publicFund ?? 0,
    nextBestMove: mission.nextBestMove ?? "Review your mission journal and claim the next strongest opportunity.",
    trainingSuggestion: mission.trainingSuggestion ?? "Go to Training Center to improve the skill gap before returning."
  });
});

Object.assign(missions.reflection_planning, {
  organization: "Home Base",
  fundingSource: "TRIO planning module",
  totalBudget: 0,
  remainingBudget: 0,
  deadlineCycles: 1,
  needType: "Planning",
  reasonWhy: "Students need a clear entry path into the city economy.",
  desiredOutcome: "Reach Client District and understand how opportunities work.",
  constraints: ["Keep it simple", "Follow the waypoint", "Use one clear action"],
  priority: "High",
  hiddenFactor: "Clarity reduces overwhelm and increases student confidence.",
  npcCompetition: "None",
  requiredSkills: [],
  requiredTools: [],
  impactReward: 0,
  publicFundBonus: 0,
  nextBestMove: "Go to Client District and talk to the Youth Program Director."
});

Object.assign(missions.skill_training_intro, {
  organization: "Training Center",
  fundingSource: "TRIO skills lab",
  totalBudget: 0,
  remainingBudget: 0,
  deadlineCycles: 3,
  needType: "Skill training",
  reasonWhy: "Students need stronger communication and prompting to compete for better contracts.",
  desiredOutcome: "Improve AI Prompting and Research before the next judged task.",
  constraints: ["Short session", "Transferable skill", "Visible improvement"],
  priority: "High",
  hiddenFactor: "Better skill alignment increases win rate more than random effort.",
  npcCompetition: "None",
  requiredSkills: [],
  requiredTools: [],
  impactReward: 0,
  publicFundBonus: 0,
  nextBestMove: "Return to Home Base or claim a stronger opportunity."
});

Object.assign(missions.youth_forward_gr, {
  organization: "Youth Forward GR",
  fundingSource: "City youth development fund",
  totalBudget: 75000,
  remainingBudget: 52000,
  deadlineCycles: 18,
  needType: "Website / Outreach",
  reasonWhy: "Low visibility and low student enrollment",
  desiredOutcome: "Increase applications by 30% in 60 days",
  constraints: ["Mobile-first", "Low budget", "Clear CTA", "Parent-friendly"],
  priority: "High",
  hiddenFactor: "Parents need trust signals before allowing students to participate",
  npcCompetition: "Medium",
  requiredSkills: [
    { key: "communication", level: 1, label: "Communication Level 1" },
    { key: "prompting", level: 1, label: "AI Prompting Level 1" }
  ],
  requiredTools: [],
  impactReward: 12,
  publicFundBonus: 50,
  taxFree: true,
  nextBestMove: "Next: Train Communication to unlock higher-value contracts.",
  trainingSuggestion: "Go to 🧠 Training Center.",
  challenge: {
    type: "pitch",
    dialog: "Youth Program Director: Our program needs more students, but families do not fully trust the current outreach.",
    choices: [
      {
        text: "I can make you a website.",
        correct: false,
        feedback: "A website alone does not solve the trust problem.",
        scores: { promptQuality: 35, outputQuality: 40, problemAlignment: 20, communication: 35 }
      },
      {
        text: "I can help market your program.",
        correct: false,
        feedback: "Marketing helps, but this still misses the parent-trust barrier.",
        scores: { promptQuality: 60, outputQuality: 55, problemAlignment: 50, communication: 60 }
      },
      {
        text: "I can build a mobile-friendly enrollment page focused on parent trust, clear benefits, and easy application steps.",
        correct: true,
        feedback: "That solution addresses the actual enrollment barrier.",
        scores: { promptQuality: 85, outputQuality: 80, problemAlignment: 95, communication: 90 }
      }
    ]
  }
});

Object.assign(missions.tool_market_intro, {
  organization: "Tool Market",
  fundingSource: "Student reinvestment budget",
  totalBudget: 5000,
  remainingBudget: 5000,
  deadlineCycles: 6,
  needType: "Tool upgrade",
  reasonWhy: "Students need the right production stack to ship better solutions faster.",
  desiredOutcome: "Buy one tool that boosts your next contract outcome.",
  constraints: ["Limited money", "Choose only what fits the mission", "Avoid tool overload"],
  priority: "Medium",
  hiddenFactor: "A good tool only matters if it supports the audience need.",
  npcCompetition: "Low",
  requiredSkills: [],
  requiredTools: [],
  impactReward: 0,
  publicFundBonus: 0,
  nextBestMove: "Use your new tool on the next outreach or web opportunity."
});

Object.assign(missions.public_fund_intro, {
  organization: "City Hall",
  fundingSource: "Public opportunity fund",
  totalBudget: 0,
  remainingBudget: 0,
  deadlineCycles: 4,
  needType: "Public fund education",
  reasonWhy: "Students need to understand how taxes convert wins into new community opportunities.",
  desiredOutcome: "Understand taxes, the public fund, and how RFPs unlock.",
  constraints: ["Short explanation", "Clear civic value", "Actionable next step"],
  priority: "Medium",
  hiddenFactor: "Civic systems can create bigger opportunities when students reinvest correctly.",
  npcCompetition: "None",
  requiredSkills: [],
  requiredTools: [],
  impactReward: 0,
  publicFundBonus: 0,
  nextBestMove: "Claim an opportunity that can grow the public fund."
});

Object.assign(missions.networking_intro, {
  organization: "Networking Hub",
  fundingSource: "Mentor network support",
  needType: "Networking",
  reasonWhy: "Students often need better questions, feedback, and positioning to improve outcomes.",
  desiredOutcome: "Collect mentor insight that strengthens the next pitch.",
  constraints: ["Use mentor time well", "Apply the advice immediately"],
  priority: "Medium",
  hiddenFactor: "Relationship insight can outperform raw technical effort.",
  requiredSkills: [{ key: "communication", level: 1, label: "Communication Level 1" }],
  impactReward: 4,
  nextBestMove: "Use the mentor advice on your next judged opportunity."
});

Object.assign(missions.opportunity_board_intro, {
  organization: "Opportunity Plaza",
  fundingSource: "City opportunity exchange",
  needType: "Opportunity analysis",
  reasonWhy: "Students need to compare scope, need, and fit before claiming work.",
  desiredOutcome: "Choose the opportunity that best fits your skills and budget.",
  constraints: ["Multiple options", "Limited time", "Need-to-reward fit matters"],
  priority: "High",
  hiddenFactor: "The best-looking contract is not always the best strategic fit.",
  impactReward: 0,
  nextBestMove: "Claim an opportunity you can actually solve well."
});

Object.assign(missions.innovation_lab_intro, {
  organization: "Innovation Lab",
  fundingSource: "Prototype innovation grant",
  needType: "Workflow prototype",
  reasonWhy: "Students need stronger prompt and output workflows to scale value.",
  desiredOutcome: "Improve prompt quality, output quality, and delivery speed.",
  constraints: ["Keep it usable", "Avoid over-automation", "Make the output clearer"],
  priority: "Medium",
  hiddenFactor: "Better systems beat one-off effort over time.",
  requiredSkills: [
    { key: "prompting", level: 1, label: "AI Prompting Level 1" },
    { key: "webDev", level: 1, label: "Web Development Level 1" }
  ],
  impactReward: 8,
  nextBestMove: "Ship the stronger workflow on a real client-facing opportunity."
});

Object.assign(missions.boss_pitch_battle, {
  organization: "Demo Arena",
  fundingSource: "Regional showcase contract",
  totalBudget: 120000,
  remainingBudget: 85000,
  deadlineCycles: 10,
  needType: "Boss pitch",
  reasonWhy: "A rival agency is competing for a higher-value contract.",
  desiredOutcome: "Win the city showcase contract with the clearest trust-centered strategy.",
  constraints: ["One shot pitch", "Rival competition", "Need measurable value"],
  priority: "High",
  hiddenFactor: "Decision-makers want a credible implementation path, not hype.",
  npcCompetition: "High",
  requiredSkills: [
    { key: "communication", level: 2, label: "Communication Level 2" },
    { key: "business", level: 1, label: "Business Strategy Level 1" }
  ],
  impactReward: 20,
  publicFundBonus: 0,
  nextBestMove: "Return to Home Base and reflect before taking on the next city-backed contract.",
  trainingSuggestion: "Go to Training Center -> Train Communication and Business Strategy.",
  challenge: {
    type: "boss",
    dialog: "NPC Agency Rival: The city wants measurable outcomes. Show why your plan is stronger.",
    choices: [
      {
        text: "Focus only on flashy visuals.",
        correct: false,
        feedback: "Visuals alone do not prove impact.",
        scores: { promptQuality: 40, outputQuality: 45, problemAlignment: 25, communication: 35 }
      },
      {
        text: "Promise everything with no delivery plan.",
        correct: false,
        feedback: "Decision-makers reject vague promises without implementation.",
        scores: { promptQuality: 30, outputQuality: 35, problemAlignment: 20, communication: 30 }
      },
      {
        text: "Present a trust-centered, measurable solution with a clear implementation path.",
        correct: true,
        feedback: "That strategy aligns value, trust, and execution.",
        scores: { promptQuality: 88, outputQuality: 82, problemAlignment: 94, communication: 90 }
      }
    ]
  }
});

Object.assign(missions.market_street_intro, {
  organization: "Market Street",
  fundingSource: "City signals board",
  needType: "Market signals",
  reasonWhy: "Students need to read demand signals before choosing what to build.",
  desiredOutcome: "Use market signals to anticipate the next strong opportunity.",
  constraints: ["Short scan", "Use signal data wisely"],
  priority: "Low",
  hiddenFactor: "Timing can matter as much as the solution itself.",
  impactReward: 0,
  nextBestMove: "Use the newsfeed and opportunity board together before claiming new work."
});

Object.assign(missions.parent_trust_sprint, {
  organization: "Parent Trust Sprint",
  fundingSource: "Community outreach partnership",
  needType: "Family outreach",
  reasonWhy: "Parents need clearer trust signals and next steps before acting.",
  desiredOutcome: "Increase family response and application confidence.",
  constraints: ["Parent-friendly voice", "Clear CTA", "Fast to deploy"],
  priority: "High",
  hiddenFactor: "Trust framing changes conversion more than generic promotion.",
  npcCompetition: "Medium",
  requiredSkills: [
    { key: "communication", level: 1, label: "Communication Level 1" },
    { key: "design", level: 1, label: "Design Level 1" }
  ],
  impactReward: 16,
  nextBestMove: "Use your outreach win to unlock stronger city-backed work."
});

Object.assign(missions.city_hall_data_story, {
  organization: "City Hall Data Story",
  fundingSource: "Public reporting office",
  needType: "Impact storytelling",
  reasonWhy: "Decision-makers need clear evidence that the public fund creates real value.",
  desiredOutcome: "Turn civic metrics into a clear impact story.",
  constraints: ["Use real numbers", "Make it understandable", "Keep it concise"],
  priority: "Medium",
  hiddenFactor: "Good evidence unlocks future funding.",
  requiredSkills: [
    { key: "research", level: 1, label: "Research Level 1" },
    { key: "business", level: 1, label: "Business Strategy Level 1" }
  ],
  impactReward: 9,
  nextBestMove: "Use this evidence to support your next RFP opportunity."
});

Object.assign(missions.innovation_lab_autoflow, {
  organization: "Innovation Autoflow",
  fundingSource: "Workflow automation pilot",
  needType: "Automation",
  reasonWhy: "Students need reusable systems that improve quality without wasting time.",
  desiredOutcome: "Build a prototype workflow that improves prompt quality and delivery speed.",
  constraints: ["Still human-centered", "Avoid complexity", "Show a measurable improvement"],
  priority: "Medium",
  hiddenFactor: "Automation is valuable only when it preserves quality and judgment.",
  requiredSkills: [
    { key: "prompting", level: 1, label: "AI Prompting Level 1" },
    { key: "webDev", level: 1, label: "Web Development Level 1" }
  ],
  impactReward: 10,
  nextBestMove: "Use your new system on a higher-value contract."
});

Object.assign(missions.mentor_network_boost, {
  organization: "Mentor Network Boost",
  fundingSource: "Professional mentor network",
  needType: "Mentor feedback",
  reasonWhy: "Students improve faster when they can test strategy with real feedback.",
  desiredOutcome: "Strengthen your next contract pitch using mentor insight.",
  constraints: ["Ask specific questions", "Use the advice quickly"],
  priority: "Low",
  hiddenFactor: "Mentor framing can reveal what the client really values.",
  requiredSkills: [{ key: "communication", level: 1, label: "Communication Level 1" }],
  impactReward: 5,
  nextBestMove: "Apply this feedback to a live opportunity immediately."
});

Object.assign(missions.city_rfp_unlock, {
  organization: "City RFP Unlock",
  fundingSource: "Public fund release",
  needType: "RFP unlock",
  reasonWhy: "Growing the public fund should release larger community-backed opportunities.",
  desiredOutcome: "Unlock a scoped city RFP using public contributions.",
  constraints: ["Need enough public fund", "Need better research and strategy"],
  priority: "High",
  hiddenFactor: "Civic opportunity opens only after collective wins increase the fund.",
  requiredSkills: [
    { key: "research", level: 2, label: "Research Level 2" },
    { key: "business", level: 1, label: "Business Strategy Level 1" }
  ],
  impactReward: 12,
  nextBestMove: "Claim the unlocked RFP and pitch a public-value solution."
});

Object.assign(missions.home_reflection_loop, {
  organization: "Home Base Reflection",
  fundingSource: "TRIO planning and reflection loop",
  totalBudget: 0,
  remainingBudget: 0,
  deadlineCycles: 2,
  needType: "Reflection",
  reasonWhy: "Students need to connect outcomes back to strategy and next action.",
  desiredOutcome: "Reflect on what worked, what was missed, and what to improve next.",
  constraints: ["Short reflection", "One clear plan", "Apply learning immediately"],
  priority: "High",
  hiddenFactor: "Reflection compounds learning across the whole city economy.",
  npcCompetition: "None",
  requiredSkills: [],
  requiredTools: [],
  impactReward: 0,
  publicFundBonus: 0,
  nextBestMove: "Choose one training action and one new opportunity before leaving Home Base."
});

Object.assign(missions.community_outreach_rfp, {
  organization: "Community Outreach RFP",
  fundingSource: "Public contributions",
  totalBudget: 140000,
  remainingBudget: 118000,
  deadlineCycles: 14,
  needType: "Community outreach RFP",
  reasonWhy: "City Hall wants a stronger outreach initiative funded by public contributions.",
  desiredOutcome: "Launch a city-wide outreach solution with measurable enrollment impact.",
  constraints: ["Requires stronger communication", "Needs research support", "Public-facing accountability"],
  priority: "High",
  hiddenFactor: "Publicly funded work demands both trust and measurable clarity.",
  npcCompetition: "High",
  requiredSkills: [
    { key: "communication", level: 2, label: "Communication Level 2" },
    { key: "research", level: 1, label: "Research Level 1" }
  ],
  requiredTools: [],
  impactReward: 20,
  publicFundBonus: 0,
  nextBestMove: "Go to Home Base to plan your next expansion after the RFP."
});

Object.assign(missions.skill_training_intro, {
  challenge: {
    type: "training",
    dialog: "Web Mentor: Before you chase bigger contracts, what is the strongest training move?",
    choices: [
      {
        text: "Open random AI tools and hope one magically fixes your pitch.",
        correct: false,
        feedback: "Tool hopping creates noise. Better training targets the real skill gap.",
        scores: { promptQuality: 30, outputQuality: 28, problemAlignment: 22, communication: 26 }
      },
      {
        text: "Practice prompt structure, sharpen research questions, and test outputs against the client's trust problem.",
        correct: true,
        feedback: "That training strategy improves the actual decision-making skill behind stronger work.",
        scores: { promptQuality: 88, outputQuality: 82, problemAlignment: 90, communication: 74 }
      },
      {
        text: "Skip practice and rely on confidence in the next meeting.",
        correct: false,
        feedback: "Confidence without better process does not reliably improve outcomes.",
        scores: { promptQuality: 24, outputQuality: 22, problemAlignment: 18, communication: 35 }
      }
    ]
  }
});

Object.assign(missions.tool_market_intro, {
  requiredTools: [],
  challenge: {
    type: "tool",
    dialog: "Design Vendor: You can only make one smart purchase right now. What should you choose?",
    choices: [
      {
        text: "Buy the flashiest premium tool even if it does not match the mission.",
        correct: false,
        feedback: "Tools should fit the audience need, not just look impressive.",
        scores: { promptQuality: 40, outputQuality: 46, problemAlignment: 24, communication: 30 }
      },
      {
        text: "Choose Website Builder because the next contract needs a simple, mobile-friendly enrollment flow.",
        correct: true,
        feedback: "That purchase directly improves delivery on a real client need.",
        scores: { promptQuality: 78, outputQuality: 84, problemAlignment: 92, communication: 66 }
      },
      {
        text: "Buy nothing forever and hope better work appears on its own.",
        correct: false,
        feedback: "Saving money matters, but refusing to invest can block higher-quality delivery.",
        scores: { promptQuality: 44, outputQuality: 34, problemAlignment: 32, communication: 38 }
      }
    ]
  }
});

Object.assign(missions.public_fund_intro, {
  challenge: {
    type: "civic",
    dialog: "City Hall Agent: How does one student contract create bigger public opportunities later?",
    choices: [
      {
        text: "It does not. Taxes leave the system and have no effect on future missions.",
        correct: false,
        feedback: "In this city economy, taxes recycle value back into future public opportunities.",
        scores: { promptQuality: 42, outputQuality: 36, problemAlignment: 20, communication: 40 }
      },
      {
        text: "Part of the contract goes into the public fund, which can unlock new city-backed RFPs.",
        correct: true,
        feedback: "Correct. Public fund growth is what expands the opportunity map.",
        scores: { promptQuality: 80, outputQuality: 78, problemAlignment: 94, communication: 70 }
      },
      {
        text: "Only private mentors create new contracts. City systems do not matter.",
        correct: false,
        feedback: "Mentors help, but civic systems are a separate opportunity engine in this game.",
        scores: { promptQuality: 46, outputQuality: 42, problemAlignment: 26, communication: 44 }
      }
    ]
  }
});

Object.assign(missions.networking_intro, {
  challenge: {
    type: "network",
    dialog: "Networking Hub Host: You only get one short conversation with a mentor. What is the best move?",
    choices: [
      {
        text: "Ask for generic motivation and leave with no clear action.",
        correct: false,
        feedback: "Encouragement helps, but specific strategic feedback is more valuable.",
        scores: { promptQuality: 38, outputQuality: 34, problemAlignment: 28, communication: 50 }
      },
      {
        text: "Ask which audience barrier matters most, what proof decision-makers need, and what to fix before the next pitch.",
        correct: true,
        feedback: "That uses mentor time well and improves the next real decision.",
        scores: { promptQuality: 82, outputQuality: 74, problemAlignment: 90, communication: 88 }
      },
      {
        text: "Spend the whole time talking about yourself and never ask a focused question.",
        correct: false,
        feedback: "Networking works best when you gather signal, not just attention.",
        scores: { promptQuality: 28, outputQuality: 24, problemAlignment: 18, communication: 36 }
      }
    ]
  }
});

Object.assign(missions.opportunity_board_intro, {
  challenge: {
    type: "strategy",
    dialog: "Opportunity Curator: Which contract should you claim first?",
    choices: [
      {
        text: "The biggest budget, even if your current skills do not match the work.",
        correct: false,
        feedback: "A larger reward is not the same as a winnable or strategic contract.",
        scores: { promptQuality: 48, outputQuality: 42, problemAlignment: 24, communication: 40 }
      },
      {
        text: "The opportunity that best fits your skills, the audience need, and a clear measurable outcome.",
        correct: true,
        feedback: "Correct. Strong fit usually beats raw contract size early on.",
        scores: { promptQuality: 84, outputQuality: 78, problemAlignment: 93, communication: 76 }
      },
      {
        text: "The hardest option, just to look ambitious, even without a delivery plan.",
        correct: false,
        feedback: "Ambition without fit usually creates weak results and lost trust.",
        scores: { promptQuality: 36, outputQuality: 32, problemAlignment: 18, communication: 34 }
      }
    ]
  }
});

Object.assign(missions.innovation_lab_intro, {
  challenge: {
    type: "prototype",
    dialog: "Innovation Lab Lead: What kind of workflow should you prototype first?",
    choices: [
      {
        text: "A huge automated system nobody on the team can explain or maintain.",
        correct: false,
        feedback: "Complexity without usability usually lowers adoption and quality.",
        scores: { promptQuality: 42, outputQuality: 48, problemAlignment: 26, communication: 30 }
      },
      {
        text: "A simple repeatable workflow that improves prompt quality, output review, and delivery speed.",
        correct: true,
        feedback: "That is the right prototype shape for an early team workflow.",
        scores: { promptQuality: 86, outputQuality: 84, problemAlignment: 91, communication: 68 }
      },
      {
        text: "No workflow at all. Just create every deliverable from scratch each time.",
        correct: false,
        feedback: "One-off effort does not scale and makes quality less reliable.",
        scores: { promptQuality: 30, outputQuality: 26, problemAlignment: 22, communication: 32 }
      }
    ]
  }
});

Object.assign(missions.market_street_intro, {
  challenge: {
    type: "signals",
    dialog: "Signal Analyst: How should you use market signals before choosing what to build next?",
    choices: [
      {
        text: "Ignore the feed and build whatever feels interesting today.",
        correct: false,
        feedback: "Interesting is not the same as timely or needed.",
        scores: { promptQuality: 34, outputQuality: 30, problemAlignment: 20, communication: 36 }
      },
      {
        text: "Compare signal trends with district needs and use them to predict the next strong opportunity.",
        correct: true,
        feedback: "Correct. Signals help you choose what the city is actually ready for.",
        scores: { promptQuality: 80, outputQuality: 74, problemAlignment: 90, communication: 70 }
      },
      {
        text: "Only copy what another student already built, without checking whether the need still exists.",
        correct: false,
        feedback: "Signal reading requires current context, not blind copying.",
        scores: { promptQuality: 44, outputQuality: 40, problemAlignment: 28, communication: 42 }
      }
    ]
  }
});

Object.assign(missions.parent_trust_sprint, {
  challenge: {
    type: "pitch",
    dialog: "Families are opening the message but not completing signup. What outreach strategy is strongest?",
    choices: [
      {
        text: "Use louder promotional language and more hype without changing the message structure.",
        correct: false,
        feedback: "Volume alone does not solve confusion or trust friction.",
        scores: { promptQuality: 48, outputQuality: 44, problemAlignment: 30, communication: 42 }
      },
      {
        text: "Build a short trust-first sequence with clear benefits, social proof, and one simple application path.",
        correct: true,
        feedback: "That removes friction and addresses the real barrier for families.",
        scores: { promptQuality: 88, outputQuality: 86, problemAlignment: 95, communication: 90 }
      },
      {
        text: "Send a long technical explanation with every program detail and no clear next step.",
        correct: false,
        feedback: "Too much information without clear action reduces completion.",
        scores: { promptQuality: 36, outputQuality: 38, problemAlignment: 24, communication: 30 }
      }
    ]
  }
});

Object.assign(missions.city_hall_data_story, {
  challenge: {
    type: "data_story",
    dialog: "City Hall Agent: What kind of impact story will persuade decision-makers to keep funding opportunity growth?",
    choices: [
      {
        text: "A vague story with no numbers, no outcomes, and no link to public value.",
        correct: false,
        feedback: "Decision-makers need evidence, not just enthusiasm.",
        scores: { promptQuality: 40, outputQuality: 34, problemAlignment: 22, communication: 38 }
      },
      {
        text: "A clear story connecting taxes, student wins, public fund growth, and measurable community outcomes.",
        correct: true,
        feedback: "That is the kind of evidence-backed story that unlocks future support.",
        scores: { promptQuality: 84, outputQuality: 82, problemAlignment: 93, communication: 78 }
      },
      {
        text: "A giant spreadsheet dump with no explanation of what matters.",
        correct: false,
        feedback: "Raw data without interpretation rarely moves a decision.",
        scores: { promptQuality: 50, outputQuality: 46, problemAlignment: 32, communication: 34 }
      }
    ]
  }
});

Object.assign(missions.innovation_lab_autoflow, {
  challenge: {
    type: "autoflow",
    dialog: "Innovation Architect: Which workflow design gives the team the strongest upgrade?",
    choices: [
      {
        text: "Automate everything and remove human review entirely.",
        correct: false,
        feedback: "Speed without judgment usually hurts quality and trust.",
        scores: { promptQuality: 52, outputQuality: 50, problemAlignment: 36, communication: 30 }
      },
      {
        text: "Create a reusable prompt checklist, output rubric, and human QA handoff that improves speed and quality.",
        correct: true,
        feedback: "That workflow keeps quality control while making the process repeatable.",
        scores: { promptQuality: 90, outputQuality: 88, problemAlignment: 94, communication: 76 }
      },
      {
        text: "Keep every workflow hidden in one person's head so nothing is documented.",
        correct: false,
        feedback: "Undocumented process does not scale and cannot be improved reliably.",
        scores: { promptQuality: 34, outputQuality: 32, problemAlignment: 20, communication: 28 }
      }
    ]
  }
});

Object.assign(missions.mentor_network_boost, {
  challenge: {
    type: "mentor",
    dialog: "Mentor Connector: What is the best way to use mentor feedback before your next proposal?",
    choices: [
      {
        text: "Collect praise only and avoid asking what is weak in your current plan.",
        correct: false,
        feedback: "Comfort does not improve your next pitch as much as targeted critique.",
        scores: { promptQuality: 38, outputQuality: 36, problemAlignment: 24, communication: 46 }
      },
      {
        text: "Ask for critique on your offer framing, audience barrier, and next proof point, then apply it immediately.",
        correct: true,
        feedback: "That turns mentor time into a concrete competitive advantage.",
        scores: { promptQuality: 82, outputQuality: 76, problemAlignment: 92, communication: 88 }
      },
      {
        text: "Save the notes somewhere and never use them in a live opportunity.",
        correct: false,
        feedback: "Feedback only creates value when it changes execution.",
        scores: { promptQuality: 44, outputQuality: 42, problemAlignment: 26, communication: 40 }
      }
    ]
  }
});

Object.assign(missions.city_rfp_unlock, {
  challenge: {
    type: "rfp",
    dialog: "RFP Curator: What unlock strategy best uses the public fund and your current readiness?",
    choices: [
      {
        text: "Open the largest civic contract possible, even if the scope is unclear and your team is unprepared.",
        correct: false,
        feedback: "Bigger scope without readiness is a fast way to lose trust.",
        scores: { promptQuality: 44, outputQuality: 40, problemAlignment: 26, communication: 36 }
      },
      {
        text: "Unlock a scoped city RFP with clear outcomes, visible public value, and a strong fit with your current skills.",
        correct: true,
        feedback: "That is the right strategic bridge into larger civic work.",
        scores: { promptQuality: 84, outputQuality: 80, problemAlignment: 94, communication: 74 }
      },
      {
        text: "Wait forever and never convert the public fund into real opportunities.",
        correct: false,
        feedback: "Public value requires action, not just accumulation.",
        scores: { promptQuality: 34, outputQuality: 32, problemAlignment: 18, communication: 30 }
      }
    ]
  }
});

Object.assign(missions.community_outreach_rfp, {
  challenge: {
    type: "boss",
    dialog: "Community Outreach Board: Why should the city trust your plan with a public-facing outreach contract?",
    choices: [
      {
        text: "Because the visuals look polished, even without a clear implementation path.",
        correct: false,
        feedback: "Public contracts require proof of delivery, not just presentation.",
        scores: { promptQuality: 52, outputQuality: 58, problemAlignment: 34, communication: 48 }
      },
      {
        text: "Because the plan is trust-first, measurable, multilingual where needed, and backed by a clear rollout path.",
        correct: true,
        feedback: "That is the strongest civic pitch in the current game loop.",
        scores: { promptQuality: 92, outputQuality: 90, problemAlignment: 96, communication: 92 }
      },
      {
        text: "Because you promise everything for everyone, with no audience focus or constraints.",
        correct: false,
        feedback: "Overpromising without focus weakens credibility.",
        scores: { promptQuality: 40, outputQuality: 42, problemAlignment: 24, communication: 38 }
      }
    ]
  }
});

const missionCatalog = [
  { id: "youth_forward_gr", locationId: "client_district", recommended: true },
  { id: "parent_trust_sprint", locationId: "client_district" },
  { id: "skill_training_intro", locationId: "training_center" },
  { id: "tool_market_intro", locationId: "tool_market" },
  { id: "home_reflection_loop", locationId: "home_base" },
  { id: "city_hall_data_story", locationId: "city_hall" },
  { id: "city_rfp_unlock", locationId: "opportunity_plaza" },
  { id: "community_outreach_rfp", locationId: "opportunity_plaza" },
  { id: "innovation_lab_autoflow", locationId: "innovation_lab" },
  { id: "mentor_network_boost", locationId: "networking_plaza" },
  { id: "boss_pitch_battle", locationId: "demo_arena" }
];

const npcDialogs = {
  board_coach: "Welcome to AI Workforce City. Explore the districts, claim opportunities, and turn skills into impact.",
  youth_director: "Families need clearer value, more trust, and a simpler next step. Can you build it?",
  youth_program_director: "Families need clearer value, more trust, and a simpler next step. Can you build it?",
  web_mentor: "Strong solutions are not just pretty. They remove friction and increase action.",
  design_vendor: "Tools help, but only when they fit the mission and the audience.",
  city_hall_agent: "Every tax contribution powers public opportunity. That fund opens bigger RFPs later.",
  mentor_connector: "Ask sharper questions and your next contract will get stronger fast.",
  rfp_curator: "Strong students do not just chase contracts. They unlock the right ones at the right time.",
  innovation_architect: "The best workflow upgrade is the one your team can actually use repeatedly.",
  signal_analyst: "Read the feed, read the city, then move before the opportunity closes.",
  npc_agency_rival: "If you want this contract, prove your strategy is stronger than mine."
};

const elements = {
  appShell: document.querySelector("#app-shell"),
  titleScreen: document.querySelector("#title-screen"),
  startGameButton: document.querySelector("#start-game-button"),
  titleDemoModeButton: document.querySelector("#title-demo-mode-button"),
  howItWorksButton: document.querySelector("#how-it-works-button"),
  howItWorksModal: document.querySelector("#how-it-works-modal"),
  closeHowItWorksButton: document.querySelector("#close-how-it-works"),
  cinematicIntro: document.querySelector("#cinematic-intro"),
  cinematicLines: [...document.querySelectorAll(".cinematic-line")],
  skipIntroButton: document.querySelector("#skip-intro-button"),
  frame: document.querySelector("#godot-frame"),
  fallback: document.querySelector("#frame-fallback"),
  screenPulse: document.querySelector("#screen-pulse"),
  rewardPopups: document.querySelector("#reward-popups"),
  confettiLayer: document.querySelector("#confetti-layer"),
  discoveryBanner: document.querySelector("#discovery-banner"),
  discoveryTitle: document.querySelector("#discovery-title"),
  discoveryBody: document.querySelector("#discovery-body"),
  money: document.querySelector("#money-value"),
  xp: document.querySelector("#xp-value"),
  xpMeterFill: document.querySelector("#xp-meter-fill"),
  level: document.querySelector("#level-value"),
  reputation: document.querySelector("#reputation-value"),
  publicFund: document.querySelector("#public-fund-value"),
  district: document.querySelector("#district-value"),
  missionPanel: document.querySelector("#mission-panel"),
  missionTitle: document.querySelector("#mission-title"),
  missionObjective: document.querySelector("#mission-objective"),
  missionSource: document.querySelector("#mission-source"),
  missionReward: document.querySelector("#mission-reward"),
  missionSkill: document.querySelector("#mission-skill"),
  missionNextStep: document.querySelector("#mission-next-step"),
  missionActions: document.querySelector("#mission-actions"),
  missionActionPrimary: document.querySelector("#mission-action-primary"),
  questTitle: document.querySelector("#quest-title"),
  questNext: document.querySelector("#quest-next"),
  questReward: document.querySelector("#quest-reward"),
  questChecklist: document.querySelector("#quest-checklist"),
  questGuidanceText: document.querySelector("#quest-guidance-text"),
  locationList: document.querySelector("#location-list"),
  npcPanel: document.querySelector("#npc-panel"),
  npcTitle: document.querySelector("#npc-title"),
  npcText: document.querySelector("#npc-text"),
  feedList: document.querySelector("#feed-list"),
  drawerPanel: document.querySelector("#drawer-panel"),
  drawerLabel: document.querySelector("#drawer-label"),
  drawerTitle: document.querySelector("#drawer-title"),
  drawerContent: document.querySelector("#drawer-content"),
  closeDrawerButton: document.querySelector("#close-drawer-button"),
  dockButtons: [...document.querySelectorAll(".dock-button[data-view]")],
  demoModeButton: document.querySelector("#demo-mode-button"),
  impactPanel: document.querySelector("#impact-panel"),
  impactTitle: document.querySelector("#impact-title"),
  impactContent: document.querySelector("#impact-content"),
  impactLearning: document.querySelector("#impact-learning"),
  impactCloseButton: document.querySelector("#impact-close-button"),
  challengePanel: document.querySelector("#challenge-panel"),
  challengeLabel: document.querySelector("#challenge-label"),
  challengeTitle: document.querySelector("#challenge-title"),
  challengeProblem: document.querySelector("#challenge-problem"),
  challengeChoices: document.querySelector("#challenge-choices"),
  challengeCloseButton: document.querySelector("#challenge-close-button"),
  npcDialogPanel: document.querySelector("#npc-dialog-panel"),
  npcDialogRole: document.querySelector("#npc-dialog-role"),
  npcDialogTitle: document.querySelector("#npc-dialog-title"),
  npcDialogPreview: document.querySelector("#npc-dialog-preview"),
  npcDialogActions: document.querySelector("#npc-dialog-actions"),
  npcDialogCloseButton: document.querySelector("#npc-dialog-close-button"),
  demoControls: document.querySelector("#demo-controls"),
  demoNextButton: document.querySelector("#demo-next-button"),
  demoStopButton: document.querySelector("#demo-stop-button"),
  touchControls: [...document.querySelectorAll("[data-input-key]")]
};

let frameReady = false;
let introTimers = [];
let pendingDemoAfterIntro = false;
let audioContext;
let discoveryTimer;
let coachIntroTimers = [];
let animatedStats = {
  money: state.money,
  xp: state.xp
};

function markFrameReady() {
  frameReady = true;
  elements.fallback.classList.add("is-hidden");
  elements.fallback.style.display = "none";
  elements.fallback.style.pointerEvents = "none";
}

function focusGodotFrame() {
  try {
    elements.frame?.focus();
    elements.frame?.contentWindow?.focus();
    elements.frame?.contentWindow?.postMessage({ type: "TRIO_REQUEST_FOCUS" }, "*");
  } catch (_error) {}
}

function forwardMovementKey(event, pressed) {
  const bridgeKeys = ["ArrowUp", "ArrowDown", "ArrowLeft", "ArrowRight", "w", "a", "s", "d", "W", "A", "S", "D", "e", "E", "q", "Q", "r", "R"];
  if (!bridgeKeys.includes(event.key)) return false;
  try {
    elements.frame?.contentWindow?.postMessage(
      {
        type: "TRIO_KEY_STATE",
        key: event.key,
        pressed
      },
      "*"
    );
  } catch (_error) {}
  return true;
}

function forwardVirtualKey(key, pressed) {
  try {
    elements.frame?.contentWindow?.postMessage(
      {
        type: "TRIO_KEY_STATE",
        key,
        pressed
      },
      "*"
    );
  } catch (_error) {}
}

elements.frame?.addEventListener("load", () => {
  markFrameReady();
  focusGodotFrame();
});

elements.frame?.addEventListener("pointerdown", focusGodotFrame);
document.querySelector(".game-stage")?.addEventListener("pointerdown", focusGodotFrame);

window.setTimeout(() => {
  try {
    if (elements.frame?.contentWindow && elements.frame.contentDocument?.readyState === "complete") {
      markFrameReady();
    }
  } catch (_error) {}
}, 600);

window.addEventListener("keydown", (event) => {
  const focusKeys = ["ArrowUp", "ArrowDown", "ArrowLeft", "ArrowRight", "w", "a", "s", "d", "W", "A", "S", "D", "e", "E", "q", "Q", "r", "R"];
  if (!focusKeys.includes(event.key)) return;
  event.preventDefault();
  forwardMovementKey(event, true);
  if (document.activeElement !== elements.frame) {
    focusGodotFrame();
  }
});

window.addEventListener("keyup", (event) => {
  if (forwardMovementKey(event, false)) {
    event.preventDefault();
  }
});

function bindTouchControls() {
  const releaseAll = () => {
    elements.touchControls.forEach((button) => {
      if (!button.dataset.pressed) return;
      button.dataset.pressed = "";
      button.classList.remove("is-pressed");
      forwardVirtualKey(button.dataset.inputKey, false);
    });
  };

  elements.touchControls.forEach((button) => {
    const press = (event) => {
      event.preventDefault();
      if (button.dataset.pressed === "true") return;
      button.dataset.pressed = "true";
      button.classList.add("is-pressed");
      focusGodotFrame();
      forwardVirtualKey(button.dataset.inputKey, true);
    };

    const release = (event) => {
      event?.preventDefault();
      if (button.dataset.pressed !== "true") return;
      button.dataset.pressed = "";
      button.classList.remove("is-pressed");
      forwardVirtualKey(button.dataset.inputKey, false);
    };

    button.addEventListener("pointerdown", press);
    button.addEventListener("pointerup", release);
    button.addEventListener("pointercancel", release);
    button.addEventListener("pointerleave", release);
  });

  window.addEventListener("pointerup", releaseAll);
  window.addEventListener("blur", releaseAll);
}

bindTouchControls();

function getLocationMeta(locationId) {
  return LOCATION_META[locationId] ?? { icon: "📍", label: locationId };
}

function formatLocationLabel(locationId, fallbackLabel) {
  const meta = getLocationMeta(locationId);
  return `${meta.icon} ${fallbackLabel ?? meta.label}`;
}

function formatMissionLabel(label, value) {
  const cleanedValue = String(value ?? "").trim().replace(/[.]+$/, "");
  return `<strong>${label}</strong> ${cleanedValue}.`;
}

function getMissionLearningOutcomes(missionId) {
  return MISSION_LEARNING_OUTCOMES[missionId] ?? [
    "Strong strategy improves mission outcomes.",
    "Clear communication creates better decisions.",
    "Skill growth unlocks stronger opportunities."
  ];
}

function getMissionSkillImprovement(missionId) {
  return MISSION_SKILL_IMPROVEMENTS[missionId] ?? `${missions[missionId]?.skill ?? "Core Skill"} +1`;
}

function resetGameState() {
  Object.keys(state).forEach((key) => {
    delete state[key];
  });
  Object.assign(state, JSON.parse(JSON.stringify(initialState)));
  animatedStats = {
    money: state.money,
    xp: state.xp
  };
  pendingDemoAfterIntro = false;
  coachIntroTimers.forEach((timer) => window.clearTimeout(timer));
  coachIntroTimers = [];
  hideDrawer();
  hideImpact();
  hideChallenge();
  hideNpcDialog();
}

function pushFeed(title, body) {
  state.feed.unshift({ title, body });
  state.feed = state.feed.slice(0, 8);
}

function emitGodotSignal(type, payload = {}) {
  elements.frame.contentWindow?.postMessage({ type, ...payload }, "*");
}

function replayAnimationClass(element, className) {
  if (!element) return;
  element.classList.remove(className);
  void element.offsetWidth;
  element.classList.add(className);
}

function clearAnimationClass(element, className, delay = 700) {
  if (!element) return;
  window.setTimeout(() => element.classList.remove(className), delay);
}

function focusGodotCamera() {
  replayAnimationClass(elements.frame, "is-panel-focus");
  clearAnimationClass(elements.frame, "is-panel-focus", 520);
  emitGodotSignal("TRIO_CAMERA_SIGNAL", { signal: "focus" });
}

function shakeGodotCamera() {
  replayAnimationClass(elements.frame, "is-camera-shake");
  clearAnimationClass(elements.frame, "is-camera-shake", 560);
  emitGodotSignal("TRIO_CAMERA_SIGNAL", { signal: "win" });
}

function pulseDistrictHighlight(districtId) {
  emitGodotSignal("TRIO_HIGHLIGHT_DISTRICT", { districtId });
}

function pulseMissionPanelGlow() {
  replayAnimationClass(elements.missionPanel, "pulse-glow");
  clearAnimationClass(elements.missionPanel, "pulse-glow", 1600);
}

function pulseReputationBadge() {
  replayAnimationClass(elements.reputation.parentElement, "pulse-glow");
  clearAnimationClass(elements.reputation.parentElement, "pulse-glow", 1400);
}

function showFloatingStatus(text, tone = "blue") {
  showRewardPopup(text, tone);
}

function burstConfetti() {
  if (!elements.confettiLayer) return;
  elements.confettiLayer.innerHTML = "";
  for (let index = 0; index < 20; index += 1) {
    const piece = document.createElement("span");
    piece.className = "confetti-piece confetti-burst";
    piece.style.left = `${8 + Math.random() * 84}%`;
    piece.style.animationDelay = `${Math.random() * 0.14}s`;
    piece.style.setProperty("--confetti-x", `${-30 + Math.random() * 60}px`);
    piece.style.setProperty("--confetti-rotate", `${Math.random() * 360}deg`);
    elements.confettiLayer.appendChild(piece);
    window.setTimeout(() => piece.remove(), 1600);
  }
}

function addFeedItem(message) {
  pushFeed("City Update", message);
}

function animateNumber(key, nextValue, format) {
  const startValue = animatedStats[key];
  const difference = nextValue - startValue;
  const startTime = performance.now();
  const duration = 720;
  const targetElement = key === "money" ? elements.money : elements.xp;

  replayAnimationClass(targetElement, "stat-count-up");
  clearAnimationClass(targetElement, "stat-count-up", duration + 120);

  function tick(timestamp) {
    const progress = Math.min(1, (timestamp - startTime) / duration);
    const eased = 1 - Math.pow(1 - progress, 3);
    animatedStats[key] = Math.round(startValue + difference * eased);
    if (key === "money") {
      targetElement.textContent = format(animatedStats[key]);
    } else if (key === "xp") {
      targetElement.textContent = format(animatedStats[key]);
    }
    if (progress < 1) {
      window.requestAnimationFrame(tick);
      return;
    }
    animatedStats[key] = nextValue;
    if (key === "money") {
      targetElement.textContent = format(nextValue);
    } else if (key === "xp") {
      targetElement.textContent = format(nextValue);
    }
  }

  window.requestAnimationFrame(tick);
}

function updateXpMeter() {
  const meterPercent = ((state.xp % 80) / 80) * 100;
  elements.xpMeterFill.style.width = `${meterPercent}%`;
}

function triggerScreenPulse() {
  elements.screenPulse.classList.remove("is-live");
  elements.screenPulse.classList.remove("screen-flash");
  void elements.screenPulse.offsetWidth;
  elements.screenPulse.classList.add("is-live");
  elements.screenPulse.classList.add("screen-flash");
}

function showRewardPopup(text, tone = "blue") {
  const popup = document.createElement("div");
  popup.className = `reward-popup reward-float ${tone ? `is-${tone}` : ""}`;
  popup.textContent = text;
  elements.rewardPopups.appendChild(popup);
  window.setTimeout(() => popup.remove(), 1400);
}

function showLevelUpPopup(level) {
  const popup = document.createElement("div");
  popup.className = "reward-popup is-purple is-level-up";
  popup.textContent = `LEVEL UP! Level ${level}`;
  elements.rewardPopups.appendChild(popup);
  window.setTimeout(() => popup.remove(), 1800);
}

function showDiscoveryBanner(title, body) {
  window.clearTimeout(discoveryTimer);
  elements.discoveryTitle.textContent = title;
  elements.discoveryBody.textContent = body;
  elements.discoveryBanner.classList.remove("is-hidden");
  discoveryTimer = window.setTimeout(() => {
    elements.discoveryBanner.classList.add("is-hidden");
  }, 3000);
}

function showRfpUnlockPopup() {
  showRewardPopup("NEW RFP UNLOCKED", "dramatic");
  showDiscoveryBanner("🏛 New RFP Unlocked", "Public Fund reached $50. Bigger city work is now open.");
  pulseDistrictHighlight("city_hall");
  shakeGodotCamera();
}

function flashMissionPanel() {
  elements.missionPanel.classList.remove("is-active");
  void elements.missionPanel.offsetWidth;
  elements.missionPanel.classList.add("is-active");
  window.setTimeout(() => {
    elements.missionPanel.classList.remove("is-active");
  }, 700);
}

function sendWaypoint(districtId) {
  state.currentWaypoint = districtId;
  elements.frame.contentWindow?.postMessage({ type: "SET_WAYPOINT", districtId }, "*");
}

function isMissionCompleted(missionId) {
  const mission = missions[missionId];
  return state.completedMissions.includes(mission?.title ?? missionId);
}

function getSkillData(key) {
  return state.skills[key];
}

function getMissingRequirements(mission) {
  const missing = [];

  (mission.requiredSkills ?? []).forEach((requirement) => {
    const skill = getSkillData(requirement.key);
    if (!skill || skill.level < requirement.level) {
      missing.push({
        type: "skill",
        key: requirement.key,
        label: requirement.label ?? `${requirement.key} Level ${requirement.level}`,
        guidance: SKILL_TRAINING_MAP[requirement.key] ?? "Go to Training Center to improve this skill."
      });
    }
  });

  (mission.requiredTools ?? []).forEach((tool) => {
    if (!state.inventory.includes(tool)) {
      missing.push({
        type: "tool",
        key: tool,
        label: tool,
        guidance: `Go to Tool Market to get ${tool}.`
      });
    }
  });

  if (mission.id === "community_outreach_rfp" && state.publicFund < PUBLIC_FUND_RFP_THRESHOLD) {
    missing.push({
      type: "rfp",
      key: "publicFund",
      label: `Public Fund $${PUBLIC_FUND_RFP_THRESHOLD}`,
      guidance: "Win contracts and pay taxes to grow the public fund."
    });
  }

  return missing;
}

function missionIsReady(mission) {
  return getMissingRequirements(mission).length === 0;
}

function formatRequiredSkills(mission) {
  return (mission.requiredSkills ?? []).length
    ? mission.requiredSkills.map((requirement) => requirement.label).join(", ")
    : "None";
}

function formatRequiredTools(mission) {
  return (mission.requiredTools ?? []).length ? mission.requiredTools.join(", ") : "None";
}

function formatConstraints(mission) {
  return (mission.constraints ?? []).join(", ");
}

function getFinalScore(scoreSet) {
  if (!scoreSet) return null;
  return Math.round(
    scoreSet.promptQuality * 0.3 +
      scoreSet.outputQuality * 0.3 +
      scoreSet.problemAlignment * 0.25 +
      scoreSet.communication * 0.15
  );
}

function maybeUnlockPublicFundRfp() {
  if (state.publicFund >= PUBLIC_FUND_RFP_THRESHOLD && !state.unlockedRfps.includes("community_outreach_rfp")) {
    state.unlockedRfps.push("community_outreach_rfp");
    pushFeed("RFP Unlocked", "City Hall released a new outreach RFP funded by public contributions.");
    showRfpUnlockPopup();
  }
}

function getSkillRecommendationFromMissing(missingRequirements) {
  const skillGap = missingRequirements.find((item) => item.type === "skill");
  if (skillGap) {
    return `Not ready yet. ${skillGap.guidance}`;
  }
  const toolGap = missingRequirements.find((item) => item.type === "tool");
  if (toolGap) {
    return `Not ready yet. ${toolGap.guidance}`;
  }
  const civicGap = missingRequirements.find((item) => item.type === "rfp");
  if (civicGap) {
    return `Not ready yet. ${civicGap.guidance}`;
  }
  return "Review the mission requirements and train before trying again.";
}

function getRecommendedGuidance() {
  if (state.nextBestMove && state.tutorial.progress.wonFirstContract) {
    return state.nextBestMove;
  }
  if (!state.tutorial.progress.reachedClientDistrict) {
    return "Go to 💼 Client District.";
  }
  if (!state.tutorial.progress.talkedToYouthDirector) {
    return "Talk to the Youth Program Director.";
  }
  if (!state.tutorial.progress.startedPitch) {
    return "Start the Youth Forward GR mission.";
  }
  if (!state.tutorial.progress.wonFirstContract) {
    return "Pick the trust-first solution.";
  }
  if (!state.tutorial.progress.reachedTrainingCenter) {
    return "Go to 🧠 Training Center.";
  }
  if (!state.tutorial.progress.returnedHome) {
    return "Go back to 🏠 Home Base.";
  }
  return "Open Mission Journal for the next contract.";
}

function getNextQuestLabel() {
  const nextStep = tutorialQuest.steps.find((step) => !state.tutorial.progress[step.id]);
  return nextStep ? nextStep.label : "Open Mission Journal for your next opportunity";
}

function renderQuestTracker() {
  const nextObjective = getRecommendedGuidance();
  const whyItMatters = state.activeMission.reward
    ? `Why: ${state.activeMission.reward}.`
    : "Why: It unlocks the next opportunity.";
  elements.questTitle.textContent = "Next Objective";
  elements.questNext.textContent = nextObjective;
  elements.questReward.textContent = whyItMatters;
  elements.questGuidanceText.textContent = `Active mission: ${state.activeMission.title}.`;
  elements.questChecklist.innerHTML = `
    <div class="quest-step is-active">
      <span class="quest-step__marker">→</span>
      <span>${nextObjective}</span>
    </div>
  `;
}

function renderLocationList() {
  elements.locationList.innerHTML = locationTargets
    .map(
      (location) => `
        <button class="location-button ${state.currentWaypoint === location.id ? "is-target pulse-glow" : ""}" data-location-id="${location.id}">
          ${formatLocationLabel(location.id, location.label)}
        </button>
      `
    )
    .join("");

  elements.locationList.querySelectorAll(".location-button").forEach((button) => {
    button.addEventListener("click", () => {
      sendWaypoint(button.dataset.locationId);
      addFeedItem(`Waypoint set: ${button.textContent.trim()}`);
      renderHud();
    });
  });
}

function playTone(type) {
  const AudioCtx = window.AudioContext || window.webkitAudioContext;
  if (!AudioCtx) return;
  if (!audioContext) {
    audioContext = new AudioCtx();
  }
  if (audioContext.state === "suspended") {
    audioContext.resume();
  }

  const oscillator = audioContext.createOscillator();
  const gainNode = audioContext.createGain();
  oscillator.connect(gainNode);
  gainNode.connect(audioContext.destination);

  const now = audioContext.currentTime;
  oscillator.type = type === "win" ? "triangle" : type === "open" ? "sine" : "square";
  oscillator.frequency.setValueAtTime(type === "win" ? 540 : type === "open" ? 420 : 220, now);
  if (type === "win") {
    oscillator.frequency.linearRampToValueAtTime(740, now + 0.16);
  }
  if (type === "error") {
    oscillator.frequency.linearRampToValueAtTime(180, now + 0.12);
  }

  gainNode.gain.setValueAtTime(0.0001, now);
  gainNode.gain.linearRampToValueAtTime(type === "win" ? 0.07 : 0.05, now + 0.02);
  gainNode.gain.exponentialRampToValueAtTime(0.0001, now + (type === "win" ? 0.32 : 0.22));

  oscillator.start(now);
  oscillator.stop(now + (type === "win" ? 0.34 : 0.24));
}

function syncLevelAndReputation() {
  const previousLevel = state.level;
  state.level = Math.max(1, Math.floor(state.xp / 80) + 1);
  Object.values(state.skills).forEach((skill) => {
    skill.level = Math.max(1, Math.floor(skill.mastery / 25) + 1);
  });

  if (state.xp >= 220) {
    state.reputation = "Market Strategist";
  } else if (state.xp >= 120) {
    state.reputation = "Trusted Pitch Builder";
  } else {
    state.reputation = "Emerging Builder";
  }

  if (state.level > previousLevel) {
    showLevelUpPopup(state.level);
  }
}

function renderHud() {
  animateNumber("money", state.money, (value) => `$${value}`);
  animateNumber("xp", state.xp, (value) => String(value));
  elements.level.textContent = String(state.level);
  elements.reputation.textContent = state.reputation;
  elements.publicFund.textContent = `$${state.publicFund}`;
  const currentDistrictId = state.activeMission?.districtId ?? state.currentWaypoint;
  elements.district.textContent = formatLocationLabel(currentDistrictId, state.currentDistrict);
  updateXpMeter();

  elements.missionTitle.textContent = state.activeMission.title;
  elements.missionObjective.innerHTML = `
    ${formatMissionLabel("💼 Problem:", state.activeMission.reasonWhy ?? state.activeMission.objective)}
    <br>
    ${formatMissionLabel("🎯 Outcome:", state.activeMission.desiredOutcome ?? state.activeMission.objective)}
    <br>
    ${formatMissionLabel("⚠️ Constraints:", formatConstraints(state.activeMission))}
    <br>
    ${formatMissionLabel("🔍 Hidden Factor:", state.activeMission.hiddenFactor ?? "Solve the real need")}
  `;
  elements.missionSource.textContent = `📍 From: ${state.activeMission.sourceName ?? "Board Coach"}`;
  elements.missionReward.textContent = `🎁 Reward: ${state.activeMission.reward}`;
  elements.missionSkill.textContent = `🧠 Skills: ${formatRequiredSkills(state.activeMission)} | 🛠 Tools: ${formatRequiredTools(state.activeMission)}`;
  elements.missionNextStep.textContent = getRecommendedGuidance();
  renderMissionActions();

  elements.feedList.innerHTML = state.feed
    .map(
      (item) => `
        <article class="feed-item">
          <strong>${item.title}</strong>
          <p>${item.body}</p>
        </article>
      `
    )
    .join("");

  renderQuestTracker();
  renderLocationList();
}

function renderMissionActions() {
  const isNpcOpportunity = state.activeMission.sourceType === "npc";
  const missingRequirements = getMissingRequirements(state.activeMission);
  const actionLabel = missingRequirements.length ? "Train First" : "Start Mission";
  elements.missionActions.innerHTML = `
    <button id="mission-action-primary" class="primary-button is-hero">${actionLabel}</button>
    ${
      isNpcOpportunity
        ? `
          <button id="mission-action-details" class="secondary-button">More Details</button>
          <button id="mission-action-leave" class="secondary-button">Close</button>
        `
        : ""
    }
  `;

  elements.missionActionPrimary = document.querySelector("#mission-action-primary");
  elements.missionActionPrimary.addEventListener("click", () => {
    if (missingRequirements.length) {
      const guidance = getSkillRecommendationFromMissing(missingRequirements);
      state.nextBestMove = guidance;
      sendWaypoint(missingRequirements.some((item) => item.type === "tool") ? "tool_market" : "training_center");
      pushFeed("Skill Recommendation", guidance);
      openDrawer("skills");
      renderHud();
      return;
    }
    showMissionChallenge(state.activeMission.missionId);
  });

  if (isNpcOpportunity) {
    document.querySelector("#mission-action-details")?.addEventListener("click", () => {
      elements.npcPanel.classList.remove("is-hidden");
      elements.npcTitle.textContent = state.activeMission.sourceName;
      elements.npcText.textContent = state.activeMission.objective;
      pushFeed("Board Coach", "This client needs trust, clarity, and a stronger path to action.");
      renderHud();
    });

    document.querySelector("#mission-action-leave")?.addEventListener("click", () => {
      elements.npcPanel.classList.add("is-hidden");
      pushFeed("City Update", `You stepped away from ${state.activeMission.sourceName}.`);
      renderHud();
    });
  }
}

function getAvailableMissionEntries() {
  return missionCatalog.filter((entry) => {
    const mission = missions[entry.id];
    if (!mission || isMissionCompleted(entry.id)) return false;
    if (entry.id === "community_outreach_rfp" && !state.unlockedRfps.includes("community_outreach_rfp")) {
      return false;
    }
    return true;
  });
}

function getLocationLabel(locationId) {
  return locationTargets.find((location) => location.id === locationId)?.label ?? locationId;
}

function resolveDistrictMissionId(districtId, fallbackMissionId) {
  switch (districtId) {
    case "home_base":
      if (state.tutorial.progress.wonFirstContract && !isMissionCompleted("home_reflection_loop")) {
        return "home_reflection_loop";
      }
      return "reflection_planning";
    case "client_district":
      if (isMissionCompleted("youth_forward_gr") && !isMissionCompleted("parent_trust_sprint")) {
        return "parent_trust_sprint";
      }
      return "youth_forward_gr";
    case "city_hall":
      return isMissionCompleted("public_fund_intro") ? "city_hall_data_story" : "public_fund_intro";
    case "networking_plaza":
      return isMissionCompleted("networking_intro") ? "mentor_network_boost" : "networking_intro";
    case "opportunity_plaza":
      if (!isMissionCompleted("opportunity_board_intro")) {
        return "opportunity_board_intro";
      }
      if (!isMissionCompleted("city_rfp_unlock")) {
        return "city_rfp_unlock";
      }
      if (state.unlockedRfps.includes("community_outreach_rfp") && !isMissionCompleted("community_outreach_rfp")) {
        return "community_outreach_rfp";
      }
      return "opportunity_board_intro";
    case "innovation_lab":
      return isMissionCompleted("innovation_lab_intro") ? "innovation_lab_autoflow" : "innovation_lab_intro";
    case "market_street":
      return "market_street_intro";
    default:
      return fallbackMissionId;
  }
}

function resolveNpcMissionId(npcId, fallbackMissionId) {
  switch (npcId) {
    case "board_coach":
      return resolveDistrictMissionId("home_base", fallbackMissionId);
    case "youth_director":
      return resolveDistrictMissionId("client_district", fallbackMissionId);
    case "city_hall_agent":
      return resolveDistrictMissionId("city_hall", fallbackMissionId);
    case "mentor_connector":
      return "mentor_network_boost";
    case "rfp_curator":
      if (state.unlockedRfps.includes("community_outreach_rfp") && !isMissionCompleted("community_outreach_rfp")) {
        return "community_outreach_rfp";
      }
      if (!isMissionCompleted("city_rfp_unlock")) {
        return "city_rfp_unlock";
      }
      return "opportunity_board_intro";
    case "innovation_architect":
      return "innovation_lab_autoflow";
    case "signal_analyst":
      return "market_street_intro";
    default:
      return fallbackMissionId;
  }
}

function bindMissionJournalActions() {
  elements.drawerContent.querySelectorAll("[data-mission-select]").forEach((button) => {
    button.addEventListener("click", () => {
      const missionId = button.dataset.missionSelect;
      const locationId = button.dataset.locationId;
      const mission = missions[missionId];
      if (!mission) return;
      state.activeMission = {
        missionId,
        districtId: locationId,
        ...mission
      };
      sendWaypoint(locationId);
      hideDrawer();
      flashMissionPanel();
      pushFeed("Mission Selected", `${mission.title} is now your active mission.`);
      renderHud();
    });
  });
}

function openDrawer(view) {
  elements.drawerPanel.classList.remove("is-hidden");

  if (view === "mission") {
    const availableMissionMarkup = getAvailableMissionEntries()
      .map((entry) => {
        const mission = missions[entry.id];
        const missingRequirements = getMissingRequirements(mission);
        return `
          <article class="inventory-item mission-journal-card">
            <strong>${mission.title}</strong>
            <p><strong>Organization:</strong> ${mission.organization}</p>
            <p><strong>Problem:</strong> ${mission.reasonWhy}</p>
            <p><strong>Outcome:</strong> ${mission.desiredOutcome}</p>
            <p>Location: ${mission.location ?? getLocationLabel(entry.locationId)}</p>
            <p>Required Skills: ${formatRequiredSkills(mission)}</p>
            <p>Required Tools: ${formatRequiredTools(mission)}</p>
            <p>Constraints: ${formatConstraints(mission)}</p>
            <p>Hidden Factor: ${mission.hiddenFactor}</p>
            <p>Reward: ${mission.reward}</p>
            <p>Status: ${missingRequirements.length ? getSkillRecommendationFromMissing(missingRequirements) : "Ready now"}</p>
            <button class="secondary-button mission-journal-button" data-mission-select="${entry.id}" data-location-id="${entry.locationId}">
              Set As Active Mission
            </button>
          </article>
        `;
      })
      .join("");

    elements.drawerLabel.textContent = "Mission Journal";
    elements.drawerTitle.textContent = "Guided Mission Path";
    elements.drawerContent.innerHTML = `
      <article class="inventory-item">
        <strong>Active Mission</strong>
        <p>${state.activeMission.title}</p>
        <p>${state.activeMission.objective}</p>
      </article>
      <article class="inventory-item">
        <strong>Recommended Next Mission</strong>
        <p>${getNextQuestLabel()}</p>
        <p>${getRecommendedGuidance()}</p>
      </article>
      <article class="inventory-item">
        <strong>Completed Missions</strong>
        <p>${state.completedMissions.length ? state.completedMissions.join(", ") : "No missions completed yet."}</p>
      </article>
      <article class="inventory-item">
        <strong>Available Missions</strong>
        <div class="drawer-scroll-list">
          ${availableMissionMarkup || "<p>No additional missions unlocked yet.</p>"}
        </div>
      </article>
    `;
    bindMissionJournalActions();
    return;
  }

  if (view === "skills") {
    elements.drawerLabel.textContent = "Skills";
    elements.drawerTitle.textContent = "Student Skill Dashboard";
    elements.drawerContent.innerHTML =
      `
        <article class="inventory-item">
          <strong>How to Improve</strong>
          <p>${getRecommendedGuidance()}</p>
        </article>
      ` +
      Object.values(state.skills)
      .map(
        (skill) => `
          <article class="skill-card">
            <strong>${skill.label}</strong>
            <span>Level ${skill.level} • ${skill.mastery}% mastery • Next unlock at ${Math.min(100, skill.level * 25 + 5)}%</span>
            <p>Train here: Training Center</p>
            <div class="skill-bar"><span style="width:${skill.mastery}%"></span></div>
          </article>
        `
      )
      .join("");
    return;
  }

  if (view === "inventory") {
    elements.drawerLabel.textContent = "Inventory";
    elements.drawerTitle.textContent = "Assets and Upgrades";
    elements.drawerContent.innerHTML = state.inventory
      .map((item) => `<article class="inventory-item"><strong>${item}</strong></article>`)
      .join("");
    return;
  }

  elements.drawerLabel.textContent = "Home";
  elements.drawerTitle.textContent = "Planning Hub";
  elements.drawerContent.innerHTML = `
    <article class="inventory-item">
      <strong>Claimed Assets</strong>
      <p>${state.claimedAssets.length ? state.claimedAssets.join(", ") : "No claimed opportunities yet."}</p>
    </article>
    <article class="inventory-item">
      <strong>Community Impact</strong>
      <p>${state.communityImpact} city impact points generated so far.</p>
    </article>
    <article class="inventory-item">
      <strong>Reflection Questions</strong>
      <p>1. What was the real problem?</p>
      <p>2. Why was "just a website" not enough?</p>
      <p>3. Which skill helped you win?</p>
      <p>4. What should you improve next?</p>
    </article>
    <article class="inventory-item">
      <strong>Next Best Move</strong>
      <p>${state.nextBestMove}</p>
    </article>
  `;
}

function hideDrawer() {
  elements.drawerPanel.classList.add("is-hidden");
}

function showImpact(title, lines, buttonLabel = "Continue Exploring", options = {}) {
  elements.impactTitle.textContent = title;
  elements.impactContent.innerHTML = lines
    .map(
      ([label, value], index) => `
        <article class="impact-stat slide-up" style="animation-delay:${index * 90}ms">
          <span class="slide-up" style="animation-delay:${index * 90}ms">${label}</span>
          <strong>${value}</strong>
        </article>
      `
    )
    .join("");
  if (options.learningOutcomes?.length) {
    elements.impactLearning.classList.remove("is-hidden");
    elements.impactLearning.innerHTML = `
      <article class="impact-learning__card">
        <p class="impact-learning__eyebrow">Real-world skill connection</p>
        <strong>You learned:</strong>
        <ul class="impact-learning__list">
          ${options.learningOutcomes.map((item) => `<li>${item}</li>`).join("")}
        </ul>
        <div class="impact-learning__skill-row">
          <span class="impact-learning__skill-label">Skill Improved</span>
          <p class="impact-learning__skill">${options.skillImproved ?? "Core Skill +1"}</p>
        </div>
      </article>
    `;
  } else {
    elements.impactLearning.classList.add("is-hidden");
    elements.impactLearning.innerHTML = "";
  }
  elements.impactCloseButton.textContent = buttonLabel;
  elements.impactPanel.classList.remove("is-hidden");
  elements.impactPanel.classList.add("is-live");
  window.setTimeout(() => elements.impactPanel.classList.remove("is-live"), 400);
}

function hideImpact() {
  elements.impactPanel.classList.add("is-hidden");
  if (demoState.active && demoState.stepIndex >= demoState.steps.length - 1) {
    stopDemoMode();
  }
}

function hideChallenge() {
  elements.challengePanel.classList.add("is-hidden");
  elements.challengePanel.classList.remove("is-live");
  elements.challengeChoices.innerHTML = "";
}

function hideNpcDialog() {
  elements.npcDialogPanel.classList.add("is-hidden");
  elements.npcDialogPanel.classList.remove("is-live");
  elements.npcDialogActions.innerHTML = "";
}

function showNpcDialog(data) {
  elements.npcDialogRole.textContent = data.npcRole ?? "City Contact";
  elements.npcDialogTitle.textContent = data.npcName ?? data.sourceName ?? "Mission Contact";
  elements.npcDialogPreview.textContent = data.dialogPreview ?? "This contact has a new opportunity for you.";
  elements.npcDialogActions.innerHTML = `
    <button id="npc-dialog-accept" class="primary-button">Accept Opportunity</button>
    <button id="npc-dialog-details" class="secondary-button">Ask for Details</button>
    <button id="npc-dialog-leave" class="secondary-button">Leave</button>
  `;
  elements.npcDialogPanel.classList.remove("is-hidden");
  elements.npcDialogPanel.classList.add("is-live");

  document.querySelector("#npc-dialog-accept")?.addEventListener("click", () => {
    hideNpcDialog();
    openMissionPanel(data);
    showMissionChallenge(data.missionId);
  });
  document.querySelector("#npc-dialog-details")?.addEventListener("click", () => {
    elements.npcDialogPreview.textContent = data.detailsText ?? `${data.dialogPreview ?? "This opportunity needs a stronger trust-centered strategy."} Reward: ${data.reward ?? "Growth + impact"}.`;
  });
  document.querySelector("#npc-dialog-leave")?.addEventListener("click", hideNpcDialog);
}

function closeHowItWorks() {
  elements.howItWorksModal.classList.add("is-hidden");
}

function openHowItWorks() {
  elements.howItWorksModal.classList.remove("is-hidden");
}

function clearIntroTimers() {
  introTimers.forEach((timer) => window.clearTimeout(timer));
  introTimers = [];
}

function runCoachIntroSequence() {
  coachIntroTimers.forEach((timer) => window.clearTimeout(timer));
  coachIntroTimers = [];
  elements.npcPanel.classList.remove("is-hidden");
  replayAnimationClass(elements.npcPanel, "fade-in");
  elements.npcTitle.textContent = "Board Coach";

  const coachLines = [
    "Welcome to AI Workforce City.",
    "Every building you see is opportunity.",
    "Let's get your first win."
  ];

  coachLines.forEach((line, index) => {
    coachIntroTimers.push(
      window.setTimeout(() => {
        elements.npcText.textContent = line;
        replayAnimationClass(elements.npcPanel, "slide-in-right");
        pushFeed("Board Coach", line);
      }, index * 1500)
    );
  });

  coachIntroTimers.push(
    window.setTimeout(() => {
      sendWaypoint("client_district");
      pulseDistrictHighlight("client_district");
      pulseMissionPanelGlow();
      showDiscoveryBanner("💼 NEXT: Client District", "Your first win starts here.");
      renderHud();
    }, 4700)
  );
}

function finishIntro(runDemo = false) {
  clearIntroTimers();
  elements.cinematicIntro.classList.add("is-hidden");
  elements.cinematicLines.forEach((line) => line.classList.remove("is-visible"));
  elements.appShell.classList.remove("is-hidden");
  sendWaypoint(state.currentWaypoint);
  const shouldRunDemo = runDemo || pendingDemoAfterIntro;
  pendingDemoAfterIntro = false;
  if (shouldRunDemo) {
    runDemoMode();
    return;
  }
  runCoachIntroSequence();
}

function startIntro(runDemo = false) {
  closeHowItWorks();
  elements.titleScreen.classList.add("is-dismissed");
  elements.appShell.classList.add("is-hidden");
  elements.cinematicIntro.classList.remove("is-hidden");
  elements.cinematicLines.forEach((line) => line.classList.remove("is-visible"));
  clearIntroTimers();
  pendingDemoAfterIntro = runDemo;

  elements.cinematicLines.forEach((line, index) => {
    introTimers.push(
      window.setTimeout(() => {
        line.classList.add("is-visible");
      }, index * 1450 + 220)
    );
  });

  introTimers.push(
    window.setTimeout(() => {
      finishIntro(runDemo);
    }, 5200)
  );
}

function setMissionForZone(zoneId) {
  const mission = missions[zoneId];
  if (!mission) return;
  state.activeMission = {
    missionId: zoneId,
    districtId: state.currentDistrict,
    ...mission
  };
}

function openMissionPanel(data) {
  const mission = missions[data.missionId];
  if (!mission) return;

  state.activeMission = {
    missionId: data.missionId,
    districtId: data.districtId ?? data.zoneId ?? state.currentDistrict,
    title: data.title ?? mission.title,
    objective: data.objective ?? mission.objective,
    organization: data.organization ?? mission.organization,
    fundingSource: data.fundingSource ?? mission.fundingSource,
    totalBudget: data.totalBudget ?? mission.totalBudget,
    remainingBudget: data.remainingBudget ?? mission.remainingBudget,
    deadlineCycles: data.deadlineCycles ?? mission.deadlineCycles,
    needType: data.needType ?? mission.needType,
    reasonWhy: data.reasonWhy ?? mission.reasonWhy,
    desiredOutcome: data.desiredOutcome ?? mission.desiredOutcome,
    constraints: data.constraints ?? mission.constraints,
    priority: data.priority ?? mission.priority,
    hiddenFactor: data.hiddenFactor ?? mission.hiddenFactor,
    npcCompetition: data.npcCompetition ?? mission.npcCompetition,
    requiredSkills: data.requiredSkills ?? mission.requiredSkills ?? [],
    requiredTools: data.requiredTools ?? mission.requiredTools ?? [],
    reward: data.reward ?? mission.reward,
    rewardMoney: data.rewardMoney ?? mission.rewardMoney ?? 0,
    rewardXP: data.rewardXP ?? mission.rewardXP ?? 0,
    rewardReputation: data.rewardReputation ?? mission.rewardReputation ?? 0,
    publicFund: data.publicFund ?? mission.publicFund ?? 0,
    publicFundBonus: data.publicFundBonus ?? mission.publicFundBonus ?? 0,
    impactReward: data.impactReward ?? mission.impactReward ?? 0,
    skill: data.skill ?? mission.skill,
    sourceType: data.sourceType ?? mission.sourceType ?? "district",
    sourceName: data.sourceName ?? data.npcName ?? data.districtName ?? mission.sourceName ?? "City Guide",
    actionLabel: data.actionLabel ?? mission.actionLabel,
    nextBestMove: data.nextBestMove ?? mission.nextBestMove,
    trainingSuggestion: data.trainingSuggestion ?? mission.trainingSuggestion,
    challenge: data.challenge ?? mission.challenge
  };

  state.nextBestMove = state.activeMission.nextBestMove ?? state.nextBestMove;

  if (state.activeMission.sourceType === "npc" && state.activeMission.missionId === "youth_forward_gr") {
    state.activeMission.actionLabel = "Accept Opportunity";
  }

  if (data.dialogPreview || data.npcName) {
    elements.npcPanel.classList.remove("is-hidden");
    elements.npcTitle.textContent = data.npcName ?? data.sourceName ?? "Mission Contact";
    elements.npcText.textContent = data.dialogPreview ?? npcDialogs[data.sourceId] ?? "This contact has useful insight for your next move.";
  }

  if (data.sourceId === "youth_director" || data.npcId === "youth_director") {
    state.tutorial.progress.talkedToYouthDirector = true;
  }

  hideChallenge();
  playTone("open");
  triggerScreenPulse();
  flashMissionPanel();
  replayAnimationClass(elements.missionPanel, "slide-in-right");
  focusGodotCamera();
  pulseMissionPanelGlow();
  showFloatingStatus("Mission Opened", "blue");
  renderHud();
}

function applyMissionOutcome(missionId, outcome = {}) {
  const mission = missions[missionId];
  if (!mission) return;

  if (isMissionCompleted(missionId) && missionId !== "community_outreach_rfp") {
    pushFeed("Mission Tracker", `${mission.title} was already completed.`);
    renderHud();
    return;
  }

  if (missionId === "reflection_planning") {
    state.xp += 10;
    state.nextBestMove = mission.nextBestMove;
    showRewardPopup("+10 XP", "purple");
    pushFeed("Board Coach", "Walk to the Client District to claim your first opportunity.");
    state.completedMissions.push(mission.title);
    sendWaypoint("client_district");
    syncLevelAndReputation();
    showImpact(
      "Mission Complete",
      [
        ["XP gained", "+10"],
        ["Next stop", "💼 Client District"]
      ],
      "Continue",
      {
        learningOutcomes: getMissionLearningOutcomes(missionId),
        skillImproved: getMissionSkillImprovement(missionId)
      }
    );
    renderHud();
    return;
  }

  if (missionId === "skill_training_intro") {
    state.xp += Math.round(mission.rewardXP * state.learningBoost);
    state.skills.prompting.mastery = Math.min(100, state.skills.prompting.mastery + 10);
    state.skills.research.mastery = Math.min(100, state.skills.research.mastery + 6);
    state.inventory.unshift("Prompt Upgrade Module");
    state.nextBestMove = mission.nextBestMove;
    state.learningBoost = 1;
    showRewardPopup(`+${mission.rewardXP} XP`, "purple");
    pushFeed("Training Complete", "Prompting and research increased in the Training Center.");
    state.completedMissions.push(mission.title);
    sendWaypoint("home_base");
    syncLevelAndReputation();
    showImpact(
      "Training Complete",
      [
        ["XP gained", `+${mission.rewardXP}`],
        ["Next stop", "🏠 Home Base"]
      ],
      "Continue",
      {
        learningOutcomes: getMissionLearningOutcomes(missionId),
        skillImproved: getMissionSkillImprovement(missionId)
      }
    );
    renderHud();
    return;
  }

  if (missionId === "tool_market_intro") {
    state.money = Math.max(0, state.money - 120);
    if (!state.inventory.includes("Website Builder")) {
      state.inventory.unshift("Website Builder");
    }
    state.nextBestMove = mission.nextBestMove;
    showRewardPopup("-$120 Tool Purchase", "gold");
    pushFeed("Tool Purchased", "Website Builder added to your inventory.");
    syncLevelAndReputation();
    showImpact(
      "Tool Purchased",
      [
        ["Money spent", "-$120"],
        ["Tool unlocked", "Website Builder"]
      ],
      "Continue",
      {
        learningOutcomes: getMissionLearningOutcomes(missionId),
        skillImproved: getMissionSkillImprovement(missionId)
      }
    );
    renderHud();
    return;
  }

  if (missionId === "public_fund_intro") {
    state.xp += 12;
    state.nextBestMove = mission.nextBestMove;
    showRewardPopup("+12 XP", "purple");
    pushFeed("City Hall", "Public fund and tax systems reviewed.");
    syncLevelAndReputation();
    showImpact(
      "Civic System Learned",
      [
        ["XP gained", "+12"],
        ["Public Fund", `$${state.publicFund}`]
      ],
      "Continue",
      {
        learningOutcomes: getMissionLearningOutcomes(missionId),
        skillImproved: getMissionSkillImprovement(missionId)
      }
    );
    renderHud();
    return;
  }

  if (missionId === "home_reflection_loop") {
    state.xp += 5;
    state.learningBoost = 1.05;
    state.nextBestMove = "Go to Training Center to improve your weakest skill, then return to Opportunity Plaza.";
    state.completedMissions.push(mission.title);
    showRewardPopup("+5 XP", "purple");
    showRewardPopup("Learning Boost +5%", "blue");
    pushFeed("Reflection Completed", "Home Base reflection finished. Your next mission gets a 5% learning boost.");
    syncLevelAndReputation();
    showImpact(
      "Reflection Complete",
      [
        ["XP gained", "+5"],
        ["Learning boost", "+5%"]
      ],
      "Continue",
      {
        learningOutcomes: getMissionLearningOutcomes(missionId),
        skillImproved: getMissionSkillImprovement(missionId)
      }
    );
    renderHud();
    return;
  }

  const grossReward = mission.rewardMoney ?? 0;
  const taxAmount = mission.taxFree ? 0 : grossReward > 0 ? Math.round(grossReward * TAX_RATE) : 0;
  const netReward = grossReward - taxAmount;
  const awardedXp = Math.round((mission.rewardXP ?? 0) * state.learningBoost);
  const reputationGain = mission.reputationReward ?? mission.rewardReputation ?? 0;
  const impactGain = mission.impactReward ?? 0;
  const scoreSet = outcome.scores ?? null;
  const finalScore = outcome.finalScore ?? getFinalScore(scoreSet);

  state.money += netReward;
  state.xp += awardedXp;
  state.publicFund += taxAmount + (mission.publicFundBonus ?? 0);
  state.communityImpact += impactGain;
  state.contractsWon += grossReward > 0 ? 1 : 0;
  state.claimedAssets.push(mission.organization);
  state.completedMissions.push(mission.title);
  state.nextBestMove = mission.nextBestMove;
  state.learningBoost = 1;

  if (reputationGain > 0) {
    showRewardPopup(`+${reputationGain} Reputation`, "green");
  }
  if (grossReward > 0) {
    showRewardPopup(`+$${netReward}`, "gold");
    if (taxAmount > 0) {
      showRewardPopup(`Taxes -$${taxAmount}`, "blue");
    }
  }
  if (awardedXp > 0) {
    showRewardPopup(`+${awardedXp} XP`, "purple");
  }
  if ((mission.publicFundBonus ?? 0) > 0) {
    showRewardPopup(`Public Fund +$${mission.publicFundBonus}`, "blue");
  }
  if (impactGain > 0) {
    showRewardPopup(`+${impactGain} Students Reached`, "green");
  }

  if (missionId === "youth_forward_gr") {
    state.skills.communication.mastery = Math.min(100, state.skills.communication.mastery + 8);
    state.skills.prompting.mastery = Math.min(100, state.skills.prompting.mastery + 6);
    state.inventory.unshift("Parent Enrollment Blueprint");
    state.tutorial.progress.wonFirstContract = true;
    sendWaypoint("training_center");
  } else if (missionId === "boss_pitch_battle") {
    state.skills.communication.mastery = Math.min(100, state.skills.communication.mastery + 10);
    state.skills.business.mastery = Math.min(100, state.skills.business.mastery + 10);
    state.inventory.unshift("Boss Pitch Trophy");
  } else if (missionId === "parent_trust_sprint") {
    state.skills.communication.mastery = Math.min(100, state.skills.communication.mastery + 9);
    state.skills.design.mastery = Math.min(100, state.skills.design.mastery + 7);
    state.inventory.unshift("Parent Trust Outreach Kit");
  } else if (missionId === "city_hall_data_story") {
    state.skills.research.mastery = Math.min(100, state.skills.research.mastery + 8);
    state.skills.business.mastery = Math.min(100, state.skills.business.mastery + 6);
    state.inventory.unshift("City Impact Storyboard");
  } else if (missionId === "innovation_lab_autoflow") {
    state.skills.prompting.mastery = Math.min(100, state.skills.prompting.mastery + 10);
    state.skills.webDev.mastery = Math.min(100, state.skills.webDev.mastery + 8);
    state.inventory.unshift("Autoflow Prototype");
  } else if (missionId === "mentor_network_boost") {
    state.skills.communication.mastery = Math.min(100, state.skills.communication.mastery + 6);
    state.skills.business.mastery = Math.min(100, state.skills.business.mastery + 5);
  } else if (missionId === "city_rfp_unlock") {
    state.skills.research.mastery = Math.min(100, state.skills.research.mastery + 10);
    state.skills.business.mastery = Math.min(100, state.skills.business.mastery + 8);
    state.claimedAssets.push("City RFP Unlock");
  } else if (missionId === "community_outreach_rfp") {
    state.skills.communication.mastery = Math.min(100, state.skills.communication.mastery + 10);
    state.skills.research.mastery = Math.min(100, state.skills.research.mastery + 7);
    state.inventory.unshift("Community Outreach Playbook");
  } else if (missionId === "networking_intro") {
    state.skills.communication.mastery = Math.min(100, state.skills.communication.mastery + 5);
  } else if (missionId === "opportunity_board_intro") {
    state.claimedAssets.push("Opportunity Slot");
  } else if (missionId === "innovation_lab_intro") {
    state.skills.prompting.mastery = Math.min(100, state.skills.prompting.mastery + 7);
    state.skills.business.mastery = Math.min(100, state.skills.business.mastery + 5);
  } else if (missionId === "market_street_intro") {
    state.skills.research.mastery = Math.min(100, state.skills.research.mastery + 5);
  }

  maybeUnlockPublicFundRfp();

  pushFeed("Mission Opened", `${mission.organization} opportunity resolved.`);
  if (grossReward > 0) {
    pushFeed("Contract Won", `${mission.organization} contract completed.`);
    if (taxAmount > 0) {
      pushFeed("Taxes Paid", `$${taxAmount} moved into the public fund.`);
    }
    pushFeed("Public Fund", `Public Fund increased to $${state.publicFund}.`);
  }
  if (missionId === "youth_forward_gr") {
    pushFeed("Skill Recommendation", "Next: Train Communication to unlock higher-value contracts.");
  }

  playTone("win");
  triggerScreenPulse();
  if (missionId === "youth_forward_gr" || missionId === "boss_pitch_battle" || missionId === "community_outreach_rfp") {
    burstConfetti();
    shakeGodotCamera();
    pulseReputationBadge();
  }
  showImpact(
    missionId === "youth_forward_gr" ? "Contract Won!" : "Workforce Impact Created",
    [
      ["Final score", finalScore ? `${finalScore}/100` : "Mission complete"],
      ["Money earned", grossReward > 0 ? `+$${netReward}` : "$0"],
      ["Public Fund contribution", taxAmount > 0 || mission.publicFundBonus ? `+$${taxAmount + (mission.publicFundBonus ?? 0)}` : "$0"],
      ["XP gained", `+${awardedXp}`],
      ["Reputation gained", reputationGain ? `+${reputationGain}` : "+0"],
      ["Students reached", impactGain ? `+${impactGain}` : "+0"]
    ],
    missionId === "youth_forward_gr" ? "Next: Train Communication" : "Continue Exploring",
    {
      learningOutcomes: getMissionLearningOutcomes(missionId),
      skillImproved: getMissionSkillImprovement(missionId)
    }
  );

  syncLevelAndReputation();
  renderHud();
}

function handleDistrictEnter(data) {
  const resolvedMissionId = resolveDistrictMissionId(data.districtId, data.missionId);
  state.currentDistrict = data.districtName;
  showDiscoveryBanner(formatLocationLabel(data.districtId, data.districtName), "Mission ready here.");
  openMissionPanel({
    missionId: resolvedMissionId,
    districtId: data.districtId,
    districtName: data.districtName,
    sourceType: "district",
    sourceName: data.districtName
  });
  addFeedItem(`Entered ${data.districtName}`);
  if (data.districtId === "client_district") {
    state.tutorial.progress.moved = true;
    state.tutorial.progress.reachedClientDistrict = true;
    pushFeed("Board Coach", "Great. Press E to open your first contract.");
  }
  if (data.districtId === "training_center") {
    state.tutorial.progress.reachedTrainingCenter = true;
  }
  if (data.districtId === "home_base" && state.tutorial.progress.reachedTrainingCenter) {
    state.tutorial.progress.returnedHome = true;
  }
  renderHud();
}

function handleNpcTalk(data) {
  const resolvedMissionId = resolveNpcMissionId(data.npcId, data.missionId);
  const resolvedMission = missions[resolvedMissionId];
  elements.npcPanel.classList.remove("is-hidden");
  elements.npcTitle.textContent = data.npcName;
  elements.npcText.textContent = data.dialogPreview ?? npcDialogs[data.npcId] ?? "This contact has useful insight for your next move.";
  openMissionPanel({
    ...data,
    missionId: resolvedMissionId,
    title: resolvedMission?.title ?? data.title,
    objective: resolvedMission?.objective ?? data.objective,
    reward: resolvedMission?.reward ?? data.reward,
    rewardMoney: resolvedMission?.rewardMoney ?? data.rewardMoney,
    rewardXP: resolvedMission?.rewardXP ?? data.rewardXP,
    rewardReputation: resolvedMission?.rewardReputation ?? data.rewardReputation,
    publicFund: resolvedMission?.publicFund ?? data.publicFund,
    skill: resolvedMission?.skill ?? data.skill
  });
  showNpcDialog({
    ...data,
    missionId: resolvedMissionId,
    title: resolvedMission?.title ?? data.title,
    objective: resolvedMission?.objective ?? data.objective,
    reward: resolvedMission?.reward ?? data.reward
  });
  addFeedItem(`Mission opened: ${resolvedMission?.title ?? data.title ?? data.npcName}`);
  renderHud();
}

function openDemoMission(data) {
  elements.npcPanel.classList.remove("is-hidden");
  elements.npcTitle.textContent = data.npcName;
  elements.npcText.textContent = data.dialogPreview ?? npcDialogs[data.npcId] ?? "This contact has useful insight for your next move.";
  openMissionPanel(data);
  addFeedItem(`Mission opened: ${data.title ?? data.npcName}`);
  hideNpcDialog();
  renderHud();
}

function showMissionChallenge(missionId) {
  const mission = missions[missionId];
  if (!mission) return;

  const missingRequirements = getMissingRequirements(mission);
  if (missingRequirements.length) {
    const guidance = getSkillRecommendationFromMissing(missingRequirements);
    state.nextBestMove = guidance;
    pushFeed("Not Ready Yet", guidance);
    showImpact("Not ready yet.", [
      ["Opportunity", mission.organization],
      ["Missing", missingRequirements.map((item) => item.label).join(", ")],
      ["Recommended next step", guidance]
    ], "Go Train");
    sendWaypoint(missingRequirements.some((item) => item.type === "tool") ? "tool_market" : "training_center");
    renderHud();
    return;
  }

  if (missionId === "home_reflection_loop") {
    elements.challengePanel.classList.remove("is-hidden");
    elements.challengeLabel.textContent = "Home Base Reflection";
    elements.challengeTitle.textContent = "Reflect and Reinvest";
    elements.challengeProblem.textContent = "What was the real problem? Why was just a website not enough? Which skill helped you win? What should you improve next?";
    elements.challengeChoices.innerHTML = `
      <button id="complete-reflection" class="primary-button">Complete Reflection</button>
    `;
    elements.challengePanel.classList.add("is-live");
    document.querySelector("#complete-reflection")?.addEventListener("click", () => {
      hideChallenge();
      applyMissionOutcome(missionId);
    });
    return;
  }

  if (mission.challenge) {
    state.tutorial.progress.startedPitch = missionId === "youth_forward_gr" ? true : state.tutorial.progress.startedPitch;
    elements.challengePanel.classList.remove("is-hidden");
    const challengeTypeLabel =
      {
        boss: "Boss Pitch",
        pitch: "Pitch Challenge",
        training: "Training Drill",
        tool: "Tool Choice",
        civic: "Civic Systems",
        network: "Networking Challenge",
        strategy: "Opportunity Strategy",
        prototype: "Prototype Challenge",
        signals: "Market Signals",
        data_story: "Impact Story",
        autoflow: "Workflow Build",
        mentor: "Mentor Strategy",
        rfp: "RFP Unlock"
      }[mission.challenge.type] ?? "Mission Challenge";
    elements.challengeLabel.textContent = challengeTypeLabel;
    elements.challengeTitle.textContent = mission.title;
    elements.challengeProblem.textContent = mission.challenge.dialog;
    elements.challengeChoices.innerHTML = mission.challenge.choices
      .map(
        (choice, index) => `
          <button class="secondary-button mission-choice" data-choice-index="${index}" data-correct="${choice.correct ? "true" : "false"}">
            ${choice.text}
          </button>
        `
      )
      .join("");
    elements.challengePanel.classList.add("is-live");
    triggerScreenPulse();
    playTone("open");
    bindMissionChoices(missionId);
    return;
  }

  applyMissionOutcome(missionId);
}

function bindMissionChoices(missionId) {
  elements.challengeChoices.querySelectorAll(".mission-choice").forEach((button) => {
    button.addEventListener("click", () => {
      const mission = missions[missionId];
      const choice = mission?.challenge?.choices?.[Number(button.dataset.choiceIndex)];
      const finalScore = getFinalScore(choice?.scores);

      if (button.dataset.correct === "true") {
        button.classList.add("is-correct");
        pulseMissionPanelGlow();
        showFloatingStatus("Great choice!", "green");
        window.setTimeout(() => {
          hideChallenge();
          applyMissionOutcome(missionId, {
            scores: choice?.scores,
            finalScore,
            choiceText: choice?.text
          });
        }, 220);
      } else {
        button.classList.add("is-wrong");
        replayAnimationClass(button, "shake");
        playTone("error");
        pushFeed("Try Again", choice?.feedback ?? "That option is weaker. Choose the strategy that builds trust and action.");
        showFloatingStatus("Try again — think about the real need.", "red");
        showImpact("Pitch Scorecard", [
          ["Final score", `${finalScore}/100`],
          ["Prompt Quality", `${choice?.scores?.promptQuality ?? 0}`],
          ["Output Quality", `${choice?.scores?.outputQuality ?? 0}`],
          ["Problem Alignment", `${choice?.scores?.problemAlignment ?? 0}`],
          ["Communication", `${choice?.scores?.communication ?? 0}`]
        ], "Try Again");
      }
    });
  });
}

function clearDemoTimers() {
  demoState.timers.forEach((timer) => window.clearTimeout(timer));
  demoState.timers = [];
}

function showDemoControls() {
  elements.demoControls.classList.remove("is-hidden");
}

function hideDemoControls() {
  elements.demoControls.classList.add("is-hidden");
}

function stopDemoMode() {
  clearDemoTimers();
  demoState.active = false;
  demoState.stepIndex = -1;
  demoState.steps = [];
  hideDemoControls();
}

function scheduleDemoAdvance(durationMs) {
  clearDemoTimers();
  if (!demoState.active || durationMs == null) return;
  demoState.timers.push(window.setTimeout(() => advanceDemoStep(), durationMs));
}

function advanceDemoStep() {
  clearDemoTimers();
  if (!demoState.active) return;
  demoState.stepIndex += 1;
  const step = demoState.steps[demoState.stepIndex];
  if (!step) {
    stopDemoMode();
    return;
  }
  step.run();
  scheduleDemoAdvance(step.durationMs);
}

function runDemoMode() {
  stopDemoMode();
  resetGameState();
  demoState.active = true;
  demoState.stepIndex = -1;
  showDemoControls();
  hideImpact();
  hideChallenge();
  hideNpcDialog();

  demoState.steps = [
    {
      durationMs: 6500,
      run: () => {
        state.currentDistrict = "Home Base";
        state.currentWaypoint = "home_base";
        state.nextBestMove = "Go to 💼 Client District.";
        sendWaypoint("home_base");
        openMissionPanel({
          missionId: "reflection_planning",
          districtId: "home_base",
          districtName: "Home Base",
          sourceType: "npc",
          sourceName: "Board Coach"
        });
        elements.npcPanel.classList.remove("is-hidden");
        elements.npcTitle.textContent = "Board Coach";
        elements.npcText.textContent = "Welcome to AI Workforce City.";
        pushFeed("Demo Mode", "Presenter walkthrough started.");
        pushFeed("Board Coach", "Welcome to AI Workforce City.");
        showDiscoveryBanner("🏠 Home Base", "Demo start.");
        renderHud();
      }
    },
    {
      durationMs: 7000,
      run: () => {
        sendWaypoint("client_district");
        state.nextBestMove = "Go to 💼 Client District.";
        pushFeed("Demo Mode", "Client District highlighted as the next stop.");
        showDiscoveryBanner("💼 Client District", "First contract ready.");
        renderHud();
      }
    },
    {
      durationMs: 7000,
      run: () => {
        handleDistrictEnter({
          districtId: "client_district",
          districtName: "Client District",
          missionId: "youth_forward_gr"
        });
        pushFeed("Demo Mode", "Arrived at Client District.");
      }
    },
    {
      durationMs: 8000,
      run: () => {
        openDemoMission({
          npcId: "youth_director",
          npcName: "Youth Program Director",
          sourceType: "npc",
          sourceName: "Youth Program Director",
          missionId: "youth_forward_gr",
          title: "Youth Forward GR",
          objective: "Build a parent-friendly enrollment solution.",
          rewardMoney: 500,
          rewardXP: 25,
          rewardReputation: 10,
          publicFund: 50,
          publicFundBonus: 50,
          skill: "Communication + AI Prompting",
          dialogPreview: "Our outreach is live, but family trust is low."
        });
      }
    },
    {
      durationMs: 9000,
      run: () => {
        showMissionChallenge("youth_forward_gr");
      }
    },
    {
      durationMs: 9000,
      run: () => {
        elements.challengeChoices.querySelector('[data-correct="true"]')?.click();
      }
    },
    {
      durationMs: 9000,
      run: () => {
        sendWaypoint("training_center");
        state.nextBestMove = "Next: Train Communication to unlock higher-value contracts.";
        showDiscoveryBanner("🏛 Public Fund +$50", "New RFP unlocked.");
        renderHud();
      }
    },
    {
      durationMs: null,
      run: () => {
        showImpact(
          "Impact Summary",
          [
            ["Contracts completed", String(state.contractsWon)],
            ["Money earned", `$${state.money - initialState.money}`],
            ["XP gained", `+${state.xp - initialState.xp}`],
            ["Students impacted", String(state.communityImpact)],
            ["Public Fund contribution", `+$${state.publicFund}`],
            ["Communication skill improved", "Yes"]
          ],
          "End Demo",
          {
            learningOutcomes: getMissionLearningOutcomes("youth_forward_gr"),
            skillImproved: getMissionSkillImprovement("youth_forward_gr")
          }
        );
      }
    }
  ];

  advanceDemoStep();
}

elements.startGameButton.addEventListener("click", () => startIntro(false));
elements.titleDemoModeButton.addEventListener("click", () => startIntro(true));
elements.howItWorksButton.addEventListener("click", openHowItWorks);
elements.closeHowItWorksButton.addEventListener("click", closeHowItWorks);
elements.skipIntroButton.addEventListener("click", () => finishIntro(pendingDemoAfterIntro));
elements.closeDrawerButton.addEventListener("click", hideDrawer);
elements.impactCloseButton.addEventListener("click", hideImpact);
elements.challengeCloseButton.addEventListener("click", hideChallenge);
elements.npcDialogCloseButton.addEventListener("click", hideNpcDialog);
elements.demoModeButton.addEventListener("click", runDemoMode);
elements.demoNextButton.addEventListener("click", advanceDemoStep);
elements.demoStopButton.addEventListener("click", stopDemoMode);

elements.dockButtons.forEach((button) => {
  button.addEventListener("click", () => {
    elements.dockButtons.forEach((item) => item.classList.remove("active"));
    button.classList.add("active");
    openDrawer(button.dataset.view);
  });
});

window.addEventListener("message", (event) => {
  const data = event.data;
  if (!data || !data.type) return;

  if (data.type === "GODOT_READY") {
    markFrameReady();
    sendWaypoint(state.currentWaypoint);
    return;
  }

  if (data.type === "GODOT_WRAPPER_READY") {
    markFrameReady();
    sendWaypoint(state.currentWaypoint);
    return;
  }

  if (data.type === "DISCOVER_DISTRICT") {
    if (!state.discoveredDistricts.includes(data.districtId)) {
      state.discoveredDistricts.push(data.districtId);
      state.xp += 5;
      showRewardPopup("+5 XP", "purple");
      showDiscoveryBanner(`District Discovered: ${data.districtName}`, data.description ?? `${data.districtName} unlocked. Explore this district to improve skills and opportunities.`);
      pushFeed("District Discovered", `${data.districtName} discovered. +5 XP.`);
      syncLevelAndReputation();
      renderHud();
      return;
    }
    addFeedItem(`You discovered ${data.districtName}`);
    return;
  }

  if (data.type === "DISCOVER_NPC") {
    if (!state.discoveredNpcs.includes(data.npcId)) {
      state.discoveredNpcs.push(data.npcId);
      state.xp += 5;
      showRewardPopup("+5 XP", "purple");
      pushFeed("Contact Found", `${data.npcName} discovered. +5 XP.`);
      syncLevelAndReputation();
      renderHud();
      return;
    }
    addFeedItem(`You found ${data.npcName}`);
    return;
  }

  if (data.type === "COLLECT_TOKEN") {
    state.xp += data.rewardXP ?? 5;
    state.inventory.unshift(data.itemName ?? "Knowledge Token");
    showRewardPopup(`+${data.rewardXP ?? 5} XP`, "purple");
    pushFeed("Discovery Reward", `${data.itemName ?? "Knowledge Token"} collected.`);
    if (data.hint) {
      pushFeed("Hidden Hint", data.hint);
    }
    syncLevelAndReputation();
    renderHud();
    return;
  }

  if (data.type === "ENTER_DISTRICT") {
    handleDistrictEnter(data);
    }

  if (data.type === "OPEN_MISSION") {
    handleNpcTalk(data);
  }
});

markFrameReady();

renderHud();
