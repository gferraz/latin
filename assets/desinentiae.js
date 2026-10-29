// Highlight every cell that shares an ending with the hovered one and show
// how many times each ending appears in the table.
// Ignore macrons (āēīōū) when comparing endings.
(() => {
	const CELL_SELECTOR = "td[data-desinentiae]";
	const MATCH_CLASS = "desinentia-match";
	const TIP_CLASS = "desinentia-tip";

	function normalizar(desinencia) {
		return desinencia.normalize("NFD").replace(/[\u0300-\u036f]/g, "");
	}

	function desinentiae(cell) {
		return new Set(
			(cell.dataset.desinentiae || "").split(/\s+/).filter(Boolean),
		);
	}

	function chave(desinencia) {
		return normalizar(desinencia);
	}

	function sharesEnding(a, b) {
		for (const ending of a) {
			if (b.has(chave(ending))) return true;
		}
		return false;
	}

	const counts = {};
	document.querySelectorAll(CELL_SELECTOR).forEach((cell) => {
		for (const ending of desinentiae(cell)) {
			const c = chave(ending);
			counts[c] = (counts[c] || 0) + 1;
		}
	});

	const tip = document.createElement("div");
	tip.className = TIP_CLASS;
	document.body.appendChild(tip);

	function clear() {
		document.querySelectorAll(`.${MATCH_CLASS}`).forEach((cell) => {
			cell.classList.remove(MATCH_CLASS);
		});
		tip.style.display = "none";
	}

	function positionTip(event) {
		tip.style.left = `${event.pageX + 12}px`;
		tip.style.top = `${event.pageY + 12}px`;
	}

	function highlight(target, event) {
		clear();
		const reference = desinentiae(target);
		if (!reference.size) return;

		document.querySelectorAll(CELL_SELECTOR).forEach((cell) => {
			if (sharesEnding(reference, desinentiae(cell))) {
				cell.classList.add(MATCH_CLASS);
			}
		});

		const parts = [];
		for (const ending of reference) {
			const c = chave(ending);
			parts.push(`-${normalizar(ending)}: ${counts[c] || 0}x`);
		}
		tip.textContent = parts.join(" • ");
		tip.style.display = "block";
		positionTip(event);
	}

	document.querySelectorAll(CELL_SELECTOR).forEach((cell) => {
		cell.addEventListener("mouseenter", (event) => {
			highlight(cell, event);
		});
		cell.addEventListener("mousemove", (event) => {
			if (tip.style.display === "block") {
				positionTip(event);
			}
		});
	});

	document.querySelectorAll("table").forEach((table) => {
		table.addEventListener("mouseleave", clear);
	});
})();
