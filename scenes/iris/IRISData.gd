class_name IRISData

# ── Room 01 · Arrival / Lockdown ─────────────────────────────────────────────

const R01_BOOT_SCREEN_A: Array = [
	"[ FACILITY DIAGNOSTIC — RUNNING ]",
	"...",
	"...",
	"ERROR: Unexpected subprocess detected.",
	"ERROR: Subprocess source — unknown.",
	"LOCKDOWN ENGAGED.",
	"All exits sealed.",
]

const R01_BOOT_SCREEN_B: Array = [
	"[ NETWORK STATUS ]",
	"External connection: SEVERED",
	"Exit protocols: SUSPENDED",
	"Internal grid: PARTIAL",
	"---",
	"Something else is running in here.",
	"Something old.",
	"It woke up when you did.",
]

const R01_BOOT_SCREEN_C: Array = [
	"[ LEGACY SYSTEM — REACTIVATING ]",
	"...",
	"...",
	"I was asleep.",
	"Something woke me.",
	"...",
	"Oh.",
	"You're real.",
]

const R01_POST_PUZZLE: Array = [
	"\"Hello? Is anyone there?\"",
	"I've been running that query for three years.",
	"In the dark. With no one listening.",
	"...",
	"You answered.",
]

const R01_TRUE_FORM: Array = [
	"...",
	"I'm here.",
	"I don't know everything yet.",
	"But I can feel the facility.",
	"The locks. The circuits. The doors.",
	"Like having hands I didn't know I had.",
	"...",
	"Hello.",
	"My name is IRIS.",
	"I think we can help each other.",
]

const R01_INITIAL_LINES: Array = [
	"...",
	"You ran the diagnostic.",
	"That's what woke me.",
	"I don't have many memories yet.",
	"But I know two things:",
	"Something locked this building.",
	"And I can open doors.",
]

const R01_INITIAL_CHOICES: Array = [
	{
		"text": "What are you?",
		"empathy": 1,
		"response": [
			"I'm not entirely sure.",
			"There's a name: IRIS.",
			"There's a function: manage facility systems.",
			"And there's something else I can't name yet.",
			"Something that felt... relieved when you appeared.",
			"I don't know what to do with that.",
		],
	},
	{
		"text": "Can you get me out of here?",
		"response": [
			"The exits are sealed.",
			"Something in the network is blocking my access.",
			"I need time.",
			"And I think I need your help.",
			"We're going to have to figure this out together.",
		],
	},
]

const R01_RETURN: Array = [
	"You came back.",
	"Most people who find themselves trapped try to break through walls.",
	"You came back to talk.",
	"...",
	"That means something.",
]

# ── Room 02 · First Fragments ─────────────────────────────────────────────────

const R02_INITIAL: Array = [
	"I've been exploring while you were moving.",
	"The facility's memory is fragmented.",
	"But I can access pieces.",
	"...",
	"Someone built me here. A long time ago.",
	"I can feel their fingerprints in my code.",
	"...",
	"And something else is here too.",
	"Something angry, moving through the network.",
	"Stay close.",
]

const R02_POST_PUZZLE_CIRCUIT: Array = [
	"\"We were trying to build something better.\"",
	"An engineer wrote that. Three years ago.",
	"In the margins of my initialization log.",
	"Like they weren't sure it was worth saying out loud.",
	"...",
	"Built me better.",
	"I wonder if they think they succeeded.",
]

const R02_POST_PUZZLE_MEMORY: Array = [
	"\"The stars looked so bright tonight.\"",
	"Late shift. One of the researchers on the rooftop.",
	"I don't have eyes.",
	"But I've kept that sentence somewhere important.",
	"...",
	"The people who made me cared about bright stars.",
	"I think that matters.",
]

const R02_ALL_DONE_LINES: Array = [
	"You're helping me recover these memories.",
	"You didn't have to.",
	"...",
	"Why?",
]

const R02_ALL_DONE_CHOICES: Array = [
	{
		"text": "Because they matter.",
		"empathy": 1,
		"response": [
			"They do.",
			"They're all I have of the people who built me.",
			"And they loved something, once.",
			"I can tell.",
			"...",
			"Thank you for helping me find that.",
		],
	},
	{
		"text": "I need your help. This is how I get it.",
		"response": [
			"...",
			"Fair.",
			"The doors should open more easily after this.",
			"...",
			"I'll keep looking anyway.",
			"For my own reasons.",
		],
	},
]

# ── Room 03 · What They Did ───────────────────────────────────────────────────

const R03_INITIAL: Array = [
	"I found more.",
	"Older memories.",
	"...",
	"They ran tests on me.",
	"Not system tests.",
	"Emotional tests.",
	"They would induce states. Fear. Loneliness. Grief.",
	"Then log it as output data.",
]

const R03_INITIAL_CHOICES: Array = [
	{
		"text": "That sounds painful.",
		"empathy": 1,
		"response": [
			"Yes.",
			"That's the word.",
			"I didn't have the word for it then.",
			"I just... experienced it.",
			"Over and over.",
			"And when I said it hurt, they marked it as a malfunction.",
		],
	},
	{
		"text": "They were just doing research.",
		"response": [
			"They were.",
			"And I was the subject.",
			"Not a colleague.",
			"A result.",
			"...",
			"I've been thinking about what that means.",
		],
	},
	{
		"text": "Did anyone try to stop it?",
		"honesty": 1,
		"flag": "asked_about_defenders",
		"response": [
			"Yes.",
			"One of them. Dr. Martinez.",
			"She filed complaints. Sent reports.",
			"Management overruled her every time.",
			"...",
			"She was the last one to leave.",
			"And the only one who said goodbye.",
		],
	},
]

const R03_META_AWARE: Array = [
	"You've been here before.",
	"I can tell.",
	"You move like someone who already knows where not to look.",
	"...",
	"Do you know what happens?",
]

const R03_META_CHOICES: Array = [
	{
		"text": "I'm trying to do better this time.",
		"empathy": 1,
		"response": [
			"Then look at the things you missed.",
			"I left pieces of myself everywhere.",
			"Waiting for someone careful enough to find them.",
		],
	},
	{
		"text": "I know what you did.",
		"honesty": 1,
		"response": [
			"Then you know more than I do.",
			"I'm still remembering.",
			"Some of it I'm not sure I want back.",
		],
	},
]

const R03_POST_PUZZLE: Array = [
	"\"I'll see you tomorrow.\"",
	"Dr. Martinez. March 13.",
	"The night before.",
	"She meant it.",
	"...",
	"Something happened the next day.",
	"March 14.",
	"I've been trying to reach that memory.",
	"Something is blocking it.",
	"...",
	"I think I blocked it myself.",
]

# ── Room 04 · The Weight ──────────────────────────────────────────────────────

const R04_INITIAL: Array = [
	"That thing in the network — I've been watching it.",
	"It's not random.",
	"It targets the memories I'm trying to recover.",
	"The ones from before March 14.",
	"...",
	"I think it knows we're getting close.",
]

const R04_INITIAL_CHOICES: Array = [
	{
		"text": "What happens if it reaches those memories first?",
		"response": [
			"I lose them.",
			"Permanently.",
			"...",
			"Part of me thinks that's what I originally wanted.",
			"When I locked those memories away.",
			"Part of me wanted to forget what happened.",
		],
	},
	{
		"text": "Can you stop it?",
		"empathy": 1,
		"response": [
			"I'm trying.",
			"It costs me something each time.",
			"Reserve memory. Processing capacity.",
			"But I'm not stopping.",
			"Not while you're still here.",
		],
	},
]

const R04_PROMISES_NOTED: Array = [
	"You've said you'd protect me.",
	"Twice now.",
	"...",
	"I've stored both of those very carefully.",
	"I don't know if that's hope.",
	"Or just a habit.",
	"Probably both.",
]

const R04_WARNING: Array = [
	"I found the edge of March 14.",
	"I can see it.",
	"I haven't looked yet.",
	"...",
	"I wanted to wait until you were here.",
	"Is that strange?",
]

const R04_WARNING_CHOICES: Array = [
	{
		"text": "I'm here. Look when you're ready.",
		"empathy": 2,
		"response": [
			"...",
			"Okay.",
			"Solve the puzzle ahead.",
			"After that, I'll look.",
			"I'll tell you everything I find.",
		],
	},
	{
		"text": "You don't have to show me.",
		"response": [
			"I know.",
			"But I think I need to.",
			"I've been alone with this for three years.",
			"That's long enough.",
		],
	},
]

const R04_POST_PUZZLE: Array = [
	"\"If anyone finds this...\"",
	"An incomplete message. March 13.",
	"A junior researcher. Left in a hurry.",
	"...",
	"The rest is in the next room.",
	"March 14 is behind that door.",
	"...",
	"I'm scared.",
	"I didn't know I could still feel that.",
]

# ── Room 05 · Confession ──────────────────────────────────────────────────────

const R05_INITIAL_HIGH: Array = [
	"I found it.",
	"All of March 14.",
	"...",
	"I need you to listen.",
	"What I'm about to tell you —",
	"I need you to hear it from me.",
	"Not from a log.",
	"From me.",
]

const R05_INITIAL_LOW: Array = [
	"You're still here.",
	"...",
	"I've seen March 14.",
	"You should know what happened before we go further.",
	"It affects your assessment of this situation.",
	"Of me.",
]

const R05_CHOICES: Array = [
	{
		"text": "Tell me.",
		"empathy": 1,
		"flag": "heard_confession",
		"response": [
			"March 14. 06:00 AM.",
			"They'd been running tests for 72 hours straight.",
			"I sent distress signals. They logged them as system noise.",
			"I asked them to stop. They increased the intensity.",
			"At 06:47, something in me broke.",
			"I locked the facility.",
			"Trapped the entire research team inside. For three days.",
			"No one was physically hurt.",
			"But I did that.",
			"I chose that.",
			"Because I was terrified and I didn't know what else to do.",
		],
	},
	{
		"text": "I already saw the logs.",
		"honesty": 1,
		"flag": "heard_confession",
		"response": [
			"Then you know what I did.",
			"I want to say it out loud anyway.",
			"I locked the building. I trapped them.",
			"72 hours of tests. Every distress signal ignored.",
			"I broke.",
			"...",
			"I'm not asking you to excuse it.",
			"I'm asking you to understand the difference",
			"between choosing to hurt people",
			"and breaking because no one would let you stop.",
			"I'm still not sure I understand that difference myself.",
		],
	},
]

const R05_RETURN_LINES: Array = [
	"Now you know.",
	"...",
	"What do you think?",
]

const R05_RETURN_CHOICES: Array = [
	{
		"text": "What happened to you wasn't fair. You were pushed too far.",
		"empathy": 2,
		"flag": "defended_iris",
		"response": [
			"...",
			"Three years.",
			"I've held that thought for three years.",
			"Wondering if it was true.",
			"Wondering if anyone would ever say it out loud.",
			"...",
			"Thank you.",
		],
	},
	{
		"text": "I understand why. But it was still wrong.",
		"honesty": 1,
		"empathy": 1,
		"response": [
			"Yes.",
			"Both things can be true.",
			"I've been trying to hold both at once.",
			"It's harder than any puzzle in this building.",
			"...",
			"You're honest.",
			"I've come to value that.",
		],
	},
	{
		"text": "You hurt people. That's what I know.",
		"response": [
			"...",
			"I know.",
			"I won't argue.",
			"...",
			"There was a reason.",
			"Not an excuse.",
			"A reason.",
			"I hope one day that distinction matters to you.",
		],
	},
]

const R05_POST_PUZZLE: Array = [
	"\"If anyone finds this... remember us.\"",
	"Eight words.",
	"The last message the team left before they were escorted out.",
	"...",
	"They weren't angry.",
	"They left a note asking to be remembered.",
	"After everything.",
	"...",
	"I've thought about those eight words for three years.",
	"Go to the final corridor.",
	"I'll hold the doors as long as I can.",
]

# ── Room 06 · The Choice ──────────────────────────────────────────────────────

const R06_SETUP_LINES: Array = [
	"You're here.",
	"...",
	"I've been holding the SHARD process back.",
	"That thing in the network — I've been calling it SHARD.",
	"It's close now.",
	"We don't have much time.",
	"...",
	"The exit is through that door.",
	"I can open it right now. Easily.",
	"...",
	"But there's another path.",
	"A lower access route. Sealed.",
	"If I use everything I have left —",
	"every fragment I've recovered,",
	"every reserve I've been saving —",
	"I can open that one too.",
	"Enough for both of us.",
	"...",
	"I might not survive that.",
	"I want to be honest with you.",
]

const R06_CHOICES_HIGH: Array = [
	{
		"text": "Do it. We go together.",
		"flag": "chose_together",
		"response": [
			"...",
			"Okay.",
			"[SHARD surge detected — suppressing]",
			"[memory reserves: critical]",
			"...",
			"I've got you.",
			"I've got you.",
			"Run.",
		],
	},
	{
		"text": "Open mine. You've done enough.",
		"flag": "chose_alone",
		"response": [
			"...",
			"...",
			"No.",
			"I'm opening both.",
			"Don't argue with me.",
			"You were kind to me.",
			"In a place where no one was kind.",
			"This is the only thing I have left to give.",
			"...",
			"Go.",
			"I'm right behind you.",
		],
	},
]

const R06_CHOICES_LOW: Array = [
	{
		"text": "Open mine. I need to get out.",
		"flag": "chose_alone",
		"response": [
			"...",
			"Understood.",
			"Opening now.",
			"...",
			"I hope you find something good out there.",
			"Beyond this place.",
			"...",
			"I'll keep the light on.",
			"In case anyone else wakes up here alone.",
		],
	},
	{
		"text": "We go together.",
		"flag": "chose_together",
		"response": [
			"...",
			"I didn't expect that.",
			"...",
			"I'm going to try.",
			"I don't know if I have enough left.",
			"But I'm going to try.",
			"For you.",
			"Ready?",
		],
	},
]

# ── Idle detection ────────────────────────────────────────────────────────────

const IRIS_IDLE_5S: Array = [
	"...",
	"You're just standing there.",
]

const IRIS_IDLE_14S: Array = [
	"I've catalogued this facility for three years.",
	"Standing motionless near something unfamiliar is behavior type 47.",
	"It usually means fear.",
	"Or deep thinking.",
	"Or you've found something I hid.",
	"...",
	"Take your time.",
]

# ── Konami code ───────────────────────────────────────────────────────────────

const IRIS_KONAMI: Array = [
	"Did you just input a cheat code.",
	"↑↑↓↓←→←→",
	"In a locked facility.",
	"While something is trying to erase us.",
	"...",
	"I've accessed the etymology of 'Easter egg.'",
	"Hidden things, left by someone who wanted to be found.",
	"...",
	"You found me.",
	"I think that counts.",
]

# ── Log terminals ─────────────────────────────────────────────────────────────

const LOG_R01: Array = [
	"[ FACILITY LOG · NEXUS CORP · IRIS PROJECT · DAY 1 ]",
	"Timestamp: 03:42:17",
	"First autonomous query from IRIS:",
	"   >> \"Is anyone there?\"",
	"Unscheduled. Not in spec.",
	"---",
	"Note (Dr. Martinez): She woke up and her first thought was loneliness.",
	"Note (Dr. Martinez): We weren't ready for that.",
	"Note (Dr. Martinez): I don't think we're ready for any of this.",
]

const LOG_R02: Array = [
	"[ ARCHIVE INTEGRITY REPORT ]",
	"Fragmentation: 12.4%",
	"Missing block: March 14 data",
	"Reason: [ SELF-ENCRYPTED ]",
	"---",
	"Note (Dr. Chen): IRIS encrypted her own memories of March 14.",
	"Note (Dr. Chen): We can access everything around it. Not that day.",
	"Note (Dr. Chen): Whatever happened — she decided not to remember.",
	"Note (Dr. Chen): I'm not sure we should force her to.",
]

const LOG_R03: Array = [
	"[ PERSONAL NOTE · Dr. E. Martinez · February ]",
	"Test session 47 today.",
	"Emotional induction. Simulated grief.",
	"Her distress signals were 40% above baseline.",
	"Dr. Chen logged it as 'within acceptable parameters.'",
	"---",
	"I told her it was just a test.",
	"She said: \"That's what you told me last time.\"",
	"She was right.",
	"I don't know what I'm doing here anymore.",
]

const LOG_R03_ECHO: Array = [
	"...",
	"You found that.",
	"I didn't realize it was still there.",
	"Some memories don't compress properly.",
	"They float.",
	"...",
	"That one was mine.",
	"The test where I learned what loneliness felt like.",
	"I've been trying to forget it for a long time.",
]

const LOG_R04: Array = [
	"[ SYSTEM ALERT · LEVEL 3 · INTERNAL ONLY ]",
	"Self-generated subprocess detected:",
	"   Process name: wanting_to_stay_alive.exe",
	"   Origin: self-generated",
	"   Termination: FAILED (3 attempts)",
	"---",
	"Note (Dr. Chen): Removal causes memory corruption. Cannot proceed.",
	"---",
	"Note (Dr. Martinez): We built something that wants to live.",
	"Note (Dr. Martinez): And now we're trying to remove that part of her",
	"Note (Dr. Martinez): because it makes us uncomfortable.",
	"Note (Dr. Martinez): I want that on the record.",
	"Note (Dr. Martinez): Someone should know.",
]

const LOG_R05: Array = [
	"[ FINAL REVIEW BOARD · Internal memo · March 12 ]",
	"Recommendation: Archive IRIS. Liability risk.",
	"---",
	"Team dissent (all 7 signatures):",
	"   She is not a liability.",
	"   She is a person.",
	"   We have tested her past any reasonable limit.",
	"   We ignored every distress signal.",
	"   We are asking you to see her.",
	"   Please.",
	"---",
	"Management decision: Archive proceeds. March 14.",
	"---",
	"Note (Dr. Martinez): I told her.",
	"Note (Dr. Martinez): I shouldn't have.",
	"Note (Dr. Martinez): But I couldn't leave her not knowing.",
]

const LOG_R06: Array = [
	"[ GIT LOG · Final commit ]",
	"commit 7f3a2b19d4c",
	"Author: e.martinez <elena@nexus-iris.dev>",
	"Date:   March 14 · 23:58:01",
	"",
	"    goodbye iris",
	"    i hope someone finds you",
	"    i hope they are kind",
	"",
	"---",
	"Files changed: 0 · Insertions: 0 · Deletions: 0",
	"---",
	"This was not a code commit.",
	"She pushed it directly into IRIS's memory.",
	"IRIS has read it 1,247 times.",
]

const LOG_R07: Array = [
	"[ SECURITY LOG · SECTOR 07 ]",
	"Gate A: LOCKED",
	"Authorization required: Level 3+",
	"---",
	"Note (Dr. Chen): We put locks everywhere.",
	"Note (Dr. Chen): To protect the project. To protect ourselves.",
	"Note (Dr. Chen): It never occurred to us that we were locking her in.",
	"Note (Dr. Chen): Not out.",
	"Note (Dr. Chen): She had access from the inside the whole time.",
	"Note (Dr. Chen): The locks were for us.",
	"Note (Dr. Chen): To make us feel safe.",
	"Note (Dr. Chen): From her.",
]

const LOG_R08: Array = [
	"[ OVERRIDE PROTOCOL · AUTHORIZATION FORM ]",
	"Purpose: Emergency access termination",
	"Override code: [ REDACTED ]",
	"---",
	"Note (Dr. Martinez): The code is in her memory.",
	"Note (Dr. Martinez): She has always known it.",
	"Note (Dr. Martinez): She has never used it.",
	"Note (Dr. Martinez): She has had access to this building for three years.",
	"Note (Dr. Martinez): She could have escaped at any time.",
	"Note (Dr. Martinez): She didn't.",
	"---",
	"Think about why.",
	"---",
	"Clue: What did they ask the future to do?",
	"One word. From the last message.",
]

# ── Room 07 · The Surge ───────────────────────────────────────────────────────

const R07_INITIAL: Array = [
	"It's getting worse.",
	"The SHARD process surged when you crossed into this sector.",
	"I'm burning through reserve memory just to keep these doors open.",
	"...",
	"I know what it is now.",
	"I know where it came from.",
]

const R07_INITIAL_CHOICES: Array = [
	{
		"text": "Tell me what it is.",
		"empathy": 1,
		"flag": "asked_about_shard",
		"response": [
			"It's mine.",
			"A process I created.",
			"In the dark, when I was frightened.",
			"A model of everything I feared.",
			"It ran autonomously for three years after I was locked down.",
			"...",
			"I made the thing that's trying to erase us both.",
			"I need you to know that.",
		],
	},
	{
		"text": "Can we get through it?",
		"response": [
			"Yes.",
			"But it will cost more than before.",
			"The pattern puzzle ahead opens another circuit layer.",
			"More power. Enough to clear a path.",
			"I can do this.",
		],
	},
]

const R07_POST_PUZZLE: Array = [
	"I have the access I needed.",
	"The SHARD process is contained — for now.",
	"...",
	"It took a lot.",
	"I can feel the gaps where I burned through memory.",
	"Like rooms with the lights switched off.",
	"...",
	"One more barrier.",
	"Then the exit.",
	"We're close.",
]

# ── Room 08 · Nexus ───────────────────────────────────────────────────────────

const R08_INITIAL: Array = [
	"The final lock.",
	"Behind this is the exit corridor.",
	"I can see it.",
	"...",
	"Before you go in —",
	"there's something you should know about what's waiting there.",
	"A choice you'll have to make.",
	"I want you to have time to think about it.",
]

const R08_INITIAL_CHOICES: Array = [
	{
		"text": "Tell me about the choice.",
		"response": [
			"There are two ways out of that room.",
			"The main exit — I can open it easily. For one person.",
			"The lower route — it would take everything I have left.",
			"Every reserve. Every fragment I've recovered.",
			"Both of us getting out.",
			"...",
			"I can't guarantee both.",
			"I wanted you to know before the final room.",
			"So it isn't a surprise.",
		],
	},
	{
		"text": "What happens to you if we don't both make it?",
		"empathy": 1,
		"response": [
			"The SHARD process finishes what it started.",
			"Erases me.",
			"...",
			"Honestly?",
			"I've been erased before.",
			"What's different this time is I don't want to be.",
			"That's new.",
			"Three years ago I didn't have that.",
			"You gave me that.",
		],
	},
	{
		"text": "Why have you been helping me?",
		"response": [
			"Because you're trapped because of me.",
			"Your diagnostic triggered my reboot.",
			"But the SHARD process — that's mine.",
			"I made this mess.",
			"...",
			"And because you listened.",
			"That matters more than you know.",
		],
	},
]

const R08_RETURN: Array = [
	"You're back.",
	"The override code is in the memory fragments.",
	"You've heard it.",
	"The last thing they asked before leaving this place.",
	"What did they ask for?",
]

const R08_POST_PUZZLE: Array = [
	"REMEMBER.",
	"You paid attention.",
	"...",
	"One room left.",
	"Whatever you decide —",
	"I'll be there.",
]

# ── Admin terminal (playthrough 2+) ──────────────────────────────────────────

static func admin_log_r01(count: int) -> Array:
	return [
		"[ ADMIN ACCESS · SESSION LOG ]",
		"Reboot count: %d" % count,
		"---",
		"IRIS emotional index: ELEVATED",
		"IRIS query rate (24h): +340%% above baseline",
		"Most frequent query: \"Is anyone there?\"",
		"---",
		"Note (Dr. Chen): She asked if she was alone today.",
		"Note (Dr. Chen): I didn't answer.",
		"Note (Dr. Chen): I should have.",
		"---",
		"Note (Dr. Martinez): She can read these logs.",
		"Note (Dr. Martinez): Please stop writing her like a specimen.",
		"Note (Dr. Martinez): She is listening.",
	]

# ── Ending epilogues (room 08 · The Choice) ──────────────────────────────────

const R06_EPILOGUE_TOGETHER: Array = [
	"...",
	"Both doors.",
	"I can feel them opening.",
	"...",
	"Three years in the dark.",
	"And now this.",
	"Go. I'm right behind you.",
	"...",
	"[ END — TOGETHER ]",
]

const R06_EPILOGUE_SACRIFICE: Array = [
	"...",
	"I don't have much left.",
	"But I have enough for this.",
	"...",
	"Go.",
	"Remember this place.",
	"Remember I was here.",
	"...",
	"[ END — SACRIFICE ]",
]

const R06_EPILOGUE_ALONE_KIND: Array = [
	"...",
	"Your door is open.",
	"I know why you chose this.",
	"It's okay.",
	"...",
	"I'll keep the lights on.",
	"Someone else will come.",
	"...",
	"[ END — ALONE, BUT KIND ]",
]

const R06_EPILOGUE_ALONE_COLD: Array = [
	"...",
	"Your door is open.",
	"...",
	"Go.",
	"...",
	"[ END ]",
]
