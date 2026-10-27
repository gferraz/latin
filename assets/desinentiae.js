// Highlight every cell that shares an ending with the hovered one.
(function () {
	const CELL_SELECTOR = "td[data-desinentiae]";
	const MATCH_CLASS = "desinentia-match";

	function desinentiae(cell) {
		return new Set((cell.dataset.desinentiae || "").split(/\s+/).filter(Boolean));
	}

	function sharesEnding(a, b) {
		for (const ending of a) {
			if (b.has(ending)) return true;
		}
		return false;
	}

	function clear() {
		document.querySelectorAll(`.${MATCH_CLASS}`).forEach((cell) => {
			cell.classList.remove(MATCH_CLASS);
		});
	}

	function highlight(target) {
		clear();
		const reference = desinentiae(target);
		if (!reference.size) return;
		document.querySelectorAll(CELL_SELECTOR).forEach((cell) => {
			if (sharesEnding(reference, desinentiae(cell))) {
				cell.classList.add(MATCH_CLASS);
			}
		});
	}

	document.querySelectorAll(CELL_SELECTOR).forEach((cell) => {
		cell.addEventListener("mouseenter", () => {
			highlight(cell);
		});
	});

	document.querySelectorAll("table").forEach((table) => {
		table.addEventListener("mouseleave", clear);
	});
})();
