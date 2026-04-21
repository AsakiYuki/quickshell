.pragma library

function timeStringToSeconds(input) {
	const arr = input.split(":")
	
	let hours = 0;
	let minutes = 0;
	let seconds = 0;

	switch (arr.length) {
		case 3:
			hours = (+arr[arr.length - 3]) || 0
		case 2:
			minutes = (+arr[arr.length - 2]) || 0
		case 1:
			seconds = (+arr[arr.length - 1]) || 0
	}
	
	return hours * 3600 + minutes * 60 + seconds;
}

function parseMxm(input) {
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

function parseLrclib(input) {
	const regex = /^\[(\d{2}:\d{2}\.\d{2})\]\s*(.+)$/;

	const result = [];
	let prev = null;

	for (const line of input.split("\n")) {
		const match = regex.exec(line);
		if (!match) continue;

		const time = timeStringToSeconds(match[1]);
		const text = match[2].trim();

		const current = {
			text,
			time: { start: time, end: undefined }
		};

		if (prev) {
			prev.time.end = time;
		}

		result.push(current);
		prev = current;
	}

	return result;
}