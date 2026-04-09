.pragma library

function fetch(input, init = {}) {
	return new Promise((resolve, reject) => {
		const xhr = new XMLHttpRequest()

		xhr.open(init.method || "GET", input, true)

		if (init.headers) {
			for (const [key, value] of Object.entries(init.headers)) {
				xhr.setRequestHeader(key, value)
			}
		}

		xhr.onload = function () {
			const response = {
				status: xhr.status,
				statusText: xhr.statusText,
				ok: xhr.status >= 200 && xhr.status < 300,
				url: xhr.responseURL,

				text: () => Promise.resolve(xhr.responseText),
				json: () => Promise.resolve().then(() => JSON.parse(xhr.responseText)),
			}

			resolve(response)
		}

		xhr.onerror = function () {
			reject(new TypeError("Network request failed"))
		}

		xhr.send(init.body || null)
	})
}
