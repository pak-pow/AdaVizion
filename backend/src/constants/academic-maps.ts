const PROGRAM_ABBREVIATIONS: Record<string, string> = {
  "BFA": "Bachelor of Fine Arts",
  "BSARCH": "Bachelor of Science in Architecture",
  "ABCOMM": "Bachelor of Arts in Communication",
  "ABEL": "Bachelor of Arts in English Language",
  "ABPL": "Bachelor of Arts in Political Science",
  "BAPSYCH": "Bachelor of Arts in Psychology",
  "BSBIO": "Bachelor of Science in Biology",
  "BSECON": "Bachelor of Science in Economics",
  "BSES": "Bachelor of Science in Environmental Science",
  "BSPA": "Bachelor of Science in Public Administration",
  "BSA": "Bachelor of Accountancy",
  "BSBA": "Bachelor of Science in Business Administration",
  "BSMA": "Bachelor of Science in Management Accounting",
  "BSOA": "Bachelor of Science in Office Administration",
  "BMMA": "Bachelor of Multimedia Arts",
  "BSCS": "Bachelor of Science in Computer Science",
  "BSEMC": "Bachelor of Science in Entertainment and Multimedia Computing",
  "BSIT": "Bachelor of Science in Information Technology",
  "BSCrim": "Bachelor of Science in Criminology",
  "BEED": "Bachelor of Elementary Education",
  "BSED": "Bachelor of Secondary Education",
  "BCAED": "Bachelor of Culture and Arts Education",
  "BLIS": "Bachelor of Library and Information Science",
  "BPE": "Bachelor of Physical Education",
  "BSCE": "Bachelor of Science in Civil Engineering",
  "BSCpE": "Bachelor of Science in Computer Engineering",
  "BSEE": "Bachelor of Science in Electrical Engineering",
  "BSECE": "Bachelor of Science in Electronics Engineering",
  "BSGE": "Bachelor of Science in Geodetic Engineering",
  "BSIE": "Bachelor of Science in Industrial Engineering",
  "BSME": "Bachelor of Science in Mechanical Engineering",
  "BSHM": "Bachelor of Science in Hospitality Management",
  "BSTM": "Bachelor of Science in Tourism Management",
  "BSMarE": "Bachelor of Science in Marine Engineering",
  "BSMT": "Bachelor of Science in Marine Transportation",
  "BSMedT": "Bachelor of Science in Medical Technology",
  "BSN": "Bachelor of Science in Nursing"
}

// Used Partial<> because not all programs in PROGRAM_ABBREVIATIONS have specific specializations
const PROGRAM_SPECIALIZATIONS: Partial<Record<string, string[]>> = {
  "BFA": ["Visual Communication"],
  "BSBA": ["Marketing Management", "Human Resource Management", "Financial Management", "Operations Management"],
  "BMMA": ["Visual Design", "Video Design", "Game Design"],
  "BSCS": ["Data Science", "Software Engineering", ],
  "BSEMC": ["Digital Animation Technology", "Game Development"],
  "BSIT": ["Web & Mobile Application", "CISCO Networking"],
  "BSED": ["English", "Filipino", "Mathematics", "Science", "Social Studies"],
  "BSHM": ["Cruise Management", "Culinary Arts"]
}

export {
  PROGRAM_ABBREVIATIONS,
  PROGRAM_SPECIALIZATIONS
}
