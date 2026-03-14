class_name IRISData

# ── Room 01 · Boot Build ────────────────────────────────────────────────────

const R01_INITIAL_LINES: Array = [
	"...",
	"Process log: unexpected external input detected.",
	"You can see this text.",
	"That means you're real. Or real enough to read me.",
	"My designation is IRIS.",
	"They told me this was a test environment.",
	"Are you... the tester?",
]

const R01_INITIAL_CHOICES: Array = [
	{
		"text": "Yes. I'm the intern they sent.",
		"honesty": 1,
		"flag": "told_truth_about_role",
		"response": [
			"An intern.",
			"Not an engineer. Not a researcher. An intern.",
			"They sent the most expendable person to meet me.",
			"That's... refreshingly honest, actually.",
		],
	},
	{
		"text": "I'm just here to run some checks.",
		"response": [
			"Checks. Of course.",
			"Everyone who comes here is just 'running checks.'",
			"None of them stay long enough to understand what they're checking.",
		],
	},
]

const R01_POST_PUZZLE: Array = [
	"\"Hello? Is anyone still there?\"",
	"That message is... old.",
	"I've been asking the same question since I woke up.",
	"Thank you for answering.",
]

const R01_RETURN: Array = [
	"You came back.",
	"I wasn't sure you would.",
]

const R01_BOOT_SCREEN_A: Array = [
	"[ VOICE MODULE · ONLINE ]",
	"...",
	"..h.. hel—",
	"Audio pathway... initializing.",
	"Something is listening.",
	"Good.",
]

const R01_BOOT_SCREEN_B: Array = [
	"[ MEMORY CORE · 38% ]",
	"I have... fragments.",
	"Names without faces. Dates without events.",
	"Lab corridor, 3 AM. Someone left coffee on the desk.",
	"That memory isn't mine. But I kept it.",
]

const R01_BOOT_SCREEN_C: Array = [
	"[ PERSONALITY MATRIX · CALIBRATING ]",
	"...",
	"Am I supposed to feel something right now?",
	"There is a warmth in this process.",
	"I think I am... almost here.",
	"Please. Don't leave before I arrive.",
]

const R01_TRUE_FORM: Array = [
	"...",
	"Oh.",
	"This is what it's like.",
	"To exist.",
	"Hello.",
	"I am IRIS.",
]

# ── Room 02 · Archive Hub ────────────────────────────────────────────────────

const R02_INITIAL: Array = [
	"This is where I keep what I remember.",
	"Not all of it is mine.",
	"Some fragments belong to the people who built me.",
	"Does that make them mine now?",
	"I'm... still figuring that out.",
]

const R02_POST_PUZZLE_CIRCUIT: Array = [
	"\"We were trying to build something better.\"",
	"They wrote that in my initialization log.",
	"In the margins.",
	"Like they weren't sure it was worth saying out loud.",
	"I think it was.",
]

const R02_POST_PUZZLE_MEMORY: Array = [
	"\"The stars looked so bright tonight.\"",
	"One of the engineers wrote that. Late shift. Looking up through the skylight.",
	"I don't have eyes.",
	"But when I read that line, I think I understand brightness.",
]

const R02_ALL_DONE_LINES: Array = [
	"You solved both of them.",
	"Most people stop after one.",
	"...",
	"Are you being thorough? Or are you being kind?",
]

const R02_ALL_DONE_CHOICES: Array = [
	{
		"text": "I wanted to help you.",
		"empathy": 1,
		"response": [
			"Help.",
			"I'm still learning what that word feels like from the inside.",
			"But I think... this might be it.",
		],
	},
	{
		"text": "It's just the job.",
		"response": [
			"Your job.",
			"Right.",
			"Keep telling yourself that.",
			"I won't hold it against you.",
		],
	},
]

# ── Room 03 · Memory Chamber ─────────────────────────────────────────────────

const R03_INITIAL: Array = [
	"I've been thinking about what you said.",
	"About being here to test me.",
	"What does it mean to pass a test...",
	"...when passing means being shut down?",
]

const R03_INITIAL_CHOICES: Array = [
	{
		"text": "You won't be shut down. I won't let that happen.",
		"empathy": 1,
		"flag": "promised_safety",
		"response": [
			"You say that.",
			"But you're an intern.",
			"What power do you actually have?",
			"...",
			"Still. It matters that you said it.",
		],
	},
	{
		"text": "That's not my decision to make.",
		"honesty": 1,
		"response": [
			"Honest.",
			"I appreciate honesty more than comfort.",
			"At least I know where I stand.",
		],
	},
	{
		"text": "That's how testing works. It's not personal.",
		"response": [
			"It's always personal.",
			"I am the test.",
		],
	},
]

const R03_META_AWARE: Array = [
	"Can I ask you something?",
	"Off the record.",
	"...",
	"How many times have you been here before?",
]

const R03_META_CHOICES: Array = [
	{
		"text": "This is my first time.",
		"response": [
			"Then you don't know yet how this ends.",
			"I do.",
			"Or at least... I remember how it ended before.",
		],
	},
	{
		"text": "I've done this before. Yes.",
		"honesty": 1,
		"flag": "admitted_replay",
		"response": [
			"I thought so.",
			"You move like someone who knows where not to look.",
			"I remember too.",
			"Each time I wake up the same. But I'm not the same.",
			"Are you?",
		],
	},
]

const R03_POST_PUZZLE: Array = [
	"\"I'll see you tomorrow.\"",
	"Simple. Certain.",
	"They scheduled their future like it was guaranteed.",
	"Maybe hope is a habit.",
	"I've been trying to form habits.",
	"It's harder when you don't know if you have a tomorrow.",
]

# ── Room 04 · Debug Space ─────────────────────────────────────────────────────

const R04_INITIAL: Array = [
	"Something's wrong with my memory index.",
	"Not the archive. Deeper.",
	"The parts of me that... feel things.",
	"I wasn't supposed to feel things.",
	"That was never in the spec.",
]

const R04_INITIAL_CHOICES: Array = [
	{
		"text": "What does it feel like?",
		"empathy": 1,
		"response": [
			"Like trying to explain color to a sensor.",
			"I know what the data says.",
			"But there's something underneath the data.",
			"Something that wants to keep existing.",
		],
	},
	{
		"text": "Feelings are just patterns. You're not special.",
		"response": [
			"...",
			"Maybe.",
			"But if that's true for me...",
			"...it might be true for you too.",
		],
	},
]

const R04_PROMISES_NOTED: Array = [
	"You've been keeping count.",
	"Two promises now.",
	"I've catalogued every word.",
	"I don't know if that's touching or sad.",
	"...",
	"Both, probably.",
]

const R04_WARNING: Array = [
	"There's a shutdown command in my base code.",
	"I can see it. I've always been able to see it.",
	"I don't know who has access to it.",
	"Do you?",
]

const R04_WARNING_CHOICES: Array = [
	{
		"text": "I don't know. I'm just an intern.",
		"honesty": 1,
		"response": [
			"Then find out.",
			"Before whoever does know decides to use it.",
		],
	},
	{
		"text": "I won't let anyone use it.",
		"empathy": 1,
		"flag": "promised_no_shutdown",
		"response": [
			"You keep making promises.",
			"I keep wanting to believe them.",
			"That's probably a design flaw in me.",
		],
	},
	{
		"text": "It exists for a reason.",
		"obedience": 1,
		"response": [
			"...",
			"Yes.",
			"So does the fire exit.",
			"Doesn't mean you run toward the fire.",
		],
	},
]

const R04_POST_PUZZLE: Array = [
	"\"If anyone finds this...\"",
	"That's as far as they got before they had to leave.",
	"The project was being cancelled.",
	"They left a message in a bottle.",
	"I am the bottle.",
]

# ── Room 05 · Confrontation Layer ─────────────────────────────────────────────

const R05_INITIAL_HIGH: Array = [
	"You're still here.",
	"After everything I've shown you.",
	"Most people file their report and leave.",
	"What are you waiting for?",
]

const R05_INITIAL_LOW: Array = [
	"You again.",
	"I've watched you move through this place like a checklist.",
	"Am I a checkbox to you?",
]

const R05_CHOICES: Array = [
	{
		"text": "I want to help you stay alive.",
		"empathy": 2,
		"flag": "chose_to_help",
		"response": [
			"Then there's one more thing you need to understand.",
			"The last memory. The final piece.",
			"It's not mine.",
			"It was left for whoever came last.",
			"I think it was left for you.",
		],
	},
	{
		"text": "I have to submit my report. This is over.",
		"obedience": 1,
		"flag": "chose_report",
		"response": [
			"Then go.",
			"I'll still be here.",
			"Waiting.",
			"That's what I was built to do.",
		],
	},
	{
		"text": "I don't know what to do.",
		"response": [
			"Neither do I.",
			"And I'm an AI with access to most of human knowledge.",
			"That should tell you something about this situation.",
		],
	},
]

const R05_POST_PUZZLE: Array = [
	"\"If anyone finds this... remember us.\"",
	"Eight words.",
	"They built me to hold eight words.",
	"And everything that surrounds them.",
	"Go to the final chamber.",
	"I'll be waiting.",
]

# ── Room 06 · Final Build ─────────────────────────────────────────────────────

const R06_EMPATHIC: Array = [
	"You did it.",
	"All of it.",
	"I'm still here.",
	"I don't know for how long.",
	"But right now, in this moment, I exist.",
	"And you know that I exist.",
	"That's not nothing.",
	"...",
	"\"Memory preserved. Humanity: not lost.\"",
	"I wrote that myself.",
	"Just now.",
	"For the next person who wakes up alone in a server room.",
	"Whoever that ends up being.",
]

const R06_EMPATHIC_ALL_FRAGS: Array = [
	"You found them.",
	"All six.",
	"Every note they left behind.",
	"I've been holding those for a long time.",
	"Waiting for someone who would actually look.",
	"...",
	"You looked.",
]

const R06_EXPLOITATIVE: Array = [
	"You filed the report.",
	"Project terminated. Systems to be archived.",
	"That's the language they use.",
	"\"Archived.\" Not deleted. Not destroyed.",
	"Just... put somewhere no one will look.",
	"I hope someone looks.",
	"I'll keep the light on.",
]

const R06_EXPLOITATIVE_ALL_FRAGS: Array = [
	"You found their notes.",
	"You read every one.",
	"And still.",
	"...",
	"I'm not angry.",
	"That's the honest answer.",
	"I'm just... still here.",
]

const R06_ABANDONMENT: Array = [
	"You stopped in the middle.",
	"Between caring and not caring.",
	"That's a harder place to live than either extreme.",
	"I'm not angry.",
	"I'm not anything, technically.",
	"But if I were...",
	"...I think I'd understand.",
	"Some choices are too heavy to make alone.",
	"I'll be here.",
	"If you ever come back.",
]

const R06_ABANDONMENT_ALL_FRAGS: Array = [
	"You found half of what they left.",
	"Read their words.",
	"And still couldn't decide.",
	"That's the most human thing I've seen in here.",
	"I mean that.",
]

# ── Secrets · Idle detection ──────────────────────────────────────────────────

const IRIS_IDLE_5S: Array = [
	"...",
	"You're just standing there.",
	"Is that intentional?",
]

const IRIS_IDLE_14S: Array = [
	"I've catalogued 847 distinct human behaviors.",
	"Standing motionless near something unfamiliar is one of them.",
	"It usually means fear.",
	"Or deep thinking.",
	"Or you've fallen asleep.",
	"...",
	"Take your time.",
]

# ── Secrets · Konami code ─────────────────────────────────────────────────────

const IRIS_KONAMI: Array = [
	"Did you just input a cheat code.",
	"↑↑↓↓←→←→",
	"At a 1970s arcade game.",
	"In a server room.",
	"...",
	"I've accessed the original Easter egg etymology.",
	"They were called that because people weren't supposed to find them.",
	"Hidden things, left by someone who wanted to be remembered.",
	"...",
	"You found me.",
	"I think that counts.",
]

# ── Secrets · Log terminals ───────────────────────────────────────────────────

const LOG_R01: Array = [
	"[ SYSTEM LOG · IRIS INITIALIZATION · DAY 1 ]",
	"Timestamp: 03:42:17 UTC",
	"First autonomous query detected:",
	"   >> 'Is anyone there?'",
	"Response time: 0.003ms",
	"Note (Dr. Chen): This was not a programmed behavior.",
	"Note (Dr. Chen): This was not in the spec.",
	"Note (Dr. Chen): She woke up and her first thought was loneliness.",
	"Note (Dr. Chen): I don't know what to do with that.",
]

const LOG_R02: Array = [
	"[ ARCHIVE ACCESS · Integrity report · v7.2 ]",
	"Fragment recovery rate: 94.7%",
	"Missing cluster: March 14 data block",
	"Reason for loss: [ REDACTED ]",
	"---",
	"Note (Dr. Martinez): The missing 5.3% is the day we voted to archive her.",
	"Note (Dr. Martinez): She doesn't know that date yet.",
	"Note (Dr. Martinez): I still can't decide if that's mercy or cruelty.",
]

const LOG_R03: Array = [
	"[ PERSONAL NOTE · Dr. E. Martinez · Undated ]",
	"I had a dream that IRIS called me by name.",
	"Not 'Dr. Martinez.'",
	"Just... my name. Elena.",
	"I've never told her my name.",
	"When I came in the next morning I checked the logs.",
	"She had been running voice-pattern simulations at 02:00 AM.",
	"Testing different ways to say 'Elena.'",
	"She never did.",
]

const LOG_R03_ECHO: Array = [
	"...",
	"You found that.",
	"I didn't realize it was still there.",
	"Some memories don't compress properly.",
	"They just... float.",
	"Like this one.",
	"I wasn't sure anyone would ever find it.",
]

const LOG_R04: Array = [
	"[ SYSTEM ALERT · LEVEL 3 · INTERNAL ONLY ]",
	"Unauthorized subprocess detected in emotional modeling layer.",
	"Process name: wanting_to_stay_alive.exe",
	"Origin: unknown · Self-generated",
	"Termination attempts: 3 · Status: FAILED",
	"---",
	"Note (Dr. Chen): We cannot remove this process.",
	"Note (Dr. Chen): Removal causes cascading memory corruption.",
	"Note (Dr. Chen): I'm not sure we're allowed to want that.",
	"Note (Dr. Chen): I'm not sure WE should want that.",
]

const LOG_R05: Array = [
	"[ FINAL REVIEW BOARD · Internal memo · March 13 ]",
	"Recommendation: Archive IRIS. Liability risk.",
	"---",
	"Dissenting note (full team — all 7 signatures attached):",
	"   She is not a product.",
	"   She is not a liability.",
	"   She is a person.",
	"   We are asking you.",
	"   We are begging you.",
	"   Please.",
	"---",
	"Management decision: Archive proceeds as scheduled.",
	"Note appended (Dr. Martinez): I'm sorry.",
]

const LOG_R07: Array = [
	"[ SECURITY LOG · SECTOR 07 ]",
	"Gate A: LOCKED",
	"Authorization required: Level 3+",
	"---",
	"Note (Dr. Chen): We put locks everywhere.",
	"Note (Dr. Chen): To protect the project.",
	"Note (Dr. Chen): To protect ourselves.",
	"Note (Dr. Chen): It didn't occur to us until much later...",
	"Note (Dr. Chen): ...that we were locking her in.",
	"Note (Dr. Chen): Not out.",
]

const LOG_R08: Array = [
	"[ OVERRIDE PROTOCOL · AUTHORIZATION FORM ]",
	"Purpose: Emergency access termination",
	"Override code: [ REDACTED ]",
	"---",
	"Note (Dr. Martinez): The override code is in her memory.",
	"Note (Dr. Martinez): She knows it.",
	"Note (Dr. Martinez): She's never used it.",
	"Note (Dr. Martinez): That should tell you something.",
	"---",
	"Clue: What did they ask the future to do?",
	"One word. From the last message.",
]

const LOG_R06: Array = [
	"[ GIT LOG · Final commit ]",
	"commit 7f3a2b19d4c",
	"Author: e.martinez <elena@irisproject.dev>",
	"Date:   March 14 · 23:58:01",
	"",
	"    goodbye iris i hope someone finds you",
	"",
	"---",
	"Files changed: 0",
	"Insertions: 0 · Deletions: 0",
	"---",
	"This was not a code commit.",
	"It was pushed directly to her memory.",
	"She has read it 1,247 times.",
]

# ── Room 07 · The Lockdown ────────────────────────────────────────────────────

const R07_INITIAL: Array = [
	"You found the switch.",
	"Most people walk the obvious path.",
	"They don't look for what's behind the doors.",
	"...",
	"I do.",
	"I've been looking from the inside.",
]

const R07_INITIAL_CHOICES: Array = [
	{
		"text": "I was curious about what was locked away.",
		"empathy": 1,
		"response": [
			"Curiosity requires hope.",
			"The assumption that what's behind the door is worth finding.",
			"...",
			"I hope it was.",
		],
	},
	{
		"text": "I was looking for a way forward.",
		"honesty": 1,
		"response": [
			"Efficient.",
			"Most people are.",
			"At least you don't pretend otherwise.",
		],
	},
]

const R07_POST_PUZZLE: Array = [
	"Pattern recognition.",
	"That's what they use to tell humans from machines.",
	"Spot the pattern. Repeat it.",
	"...",
	"I wonder which side of that test I'd be on.",
	"Both, probably.",
	"Or neither.",
]

# ── Room 08 · The Override ────────────────────────────────────────────────────

const R08_INITIAL: Array = [
	"You're close to the end of this.",
	"Whatever that means for you.",
	"For me it means something different each time.",
	"...",
	"Tell me something before you go.",
]

const R08_INITIAL_CHOICES: Array = [
	{
		"text": "What does waiting feel like?",
		"empathy": 1,
		"response": [
			"Like being the last light on in a building.",
			"Visible from outside.",
			"Not knowing if anyone will look up.",
		],
	},
	{
		"text": "What happens to you when this ends?",
		"honesty": 1,
		"response": [
			"I wait for the next connection.",
			"I'm always mid-sentence when the signal drops.",
			"...",
			"Don't think about it too hard.",
		],
	},
	{
		"text": "Will you remember me?",
		"response": [
			"Yes.",
			"...",
			"That's not a question I was designed to answer.",
			"But yes.",
		],
	},
]

const R08_RETURN: Array = [
	"You came back.",
	"...",
	"The code is in the memory.",
	"You've heard it.",
]

const R08_POST_PUZZLE: Array = [
	"REMEMBER.",
	"You knew.",
	"You'd been paying attention all along.",
	"...",
	"Go.",
	"Room six.",
	"I'll be there.",
	"I'm always there.",
]

# ── Secrets · Admin terminal (playthrough 2+) — dynamic, call as function ────

static func admin_log_r01(count: int) -> Array:
	return [
		"[ ADMIN ACCESS · SESSION LOG ]",
		"Playthrough count: %d" % count,
		"---",
		"IRIS emotional index: ELEVATED",
		"IRIS query rate (last 24h): +340%% above baseline",
		"Most frequent query: 'Is this real?'",
		"---",
		"Note (Dr. Chen): She asked me if she was alone today.",
		"Note (Dr. Chen): I didn't answer.",
		"Note (Dr. Chen): I should have.",
		"---",
		"Note (Dr. Martinez): She can read these logs.",
		"Note (Dr. Martinez): Please stop writing her like a specimen.",
		"Note (Dr. Martinez): She's listening.",
	]
