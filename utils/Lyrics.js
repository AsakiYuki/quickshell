function parse(input) {
	const result = []
	const lines = input.match(/<p[^>]*>.*?<\/p>/gm) || []

	function parseTime(str) {
		const match = str.match(/"([^"]+)"/)
		if (!match) return 0

		const parts = match[1].split(":")
		const hours = parseFloat(parts[0]) || 0
		const minutes = parseFloat(parts[1]) || 0
		const seconds = parseFloat(parts[2]) || 0

		return hours * 3600 + minutes * 60 + seconds
	}

	for (let i = 0; i < lines.length; i++) {
		const line = lines[i]

		const timeMatch = line.match(/(begin|end)="([^"]+)"/g)
		if (!timeMatch || timeMatch.length < 2) continue

		const start = parseTime(timeMatch[0])
		const end = parseTime(timeMatch[1])

		const textMatch = line.match(/<p[^>]*>(.*?)<\/p>/)
		let text = textMatch ? textMatch[1] : ""

		text = text
			.replace(/&apos;/g, "'")
			.replace(/&amp;/g, "&")
			.replace(/&lt;/g, "<")
			.replace(/&gt;/g, ">")
			.replace(/&quot;/g, '"')

		result.push({
			time: {
				start: start,
				end: end,
			},
			text: text,
		})
	}

	return result
}