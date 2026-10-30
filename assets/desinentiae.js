// Highlight every cell that shares an ending with the hovered one and show
// how many times each ending appears in the table. Detail lines are ordered by
// case, then declension, then number.
// Ignore macrons (āēīōū) when comparing endings.
(() => {
	const CELL_SELECTOR = "td[data-desinentiae]";
	const MATCH_CLASS = "desinentia-match";
	const TIP_CLASS = "desinentia-tip";
	const CASUS_ORDER = ["nominativus", "vocativus", "accusativus", "genitivus", "dativus", "ablativus"];
	const DECLINATIO_ORDER = ["I", "II", "III", "IV", "V"];
	const NUMERUS_ORDER = ["singularis", "pluralis"];

	function normalize(desinencia) {
		return desinencia.normalize("NFD").replace(/[\u0300-\u036f]/g, "");
	}

	function desinentiae(cell) {
		return new Set(
			(cell.dataset.desinentiae || "").split(/\s+/).filter(Boolean).map(normalize),
		);
	}

	function sharesEnding(a, b) {
		for (const ending of a) {
			if (b.has(ending)) return true;
		}
		return false;
	}

	function analysisOf(cell) {
		const [casus = "", numerus = "", declinatio = ""] = (cell.dataset.analysis || "").split(" · ");
		return {
			casus: casus.split(" / ")[0],
			numerus,
			declinatio: declinatio.replace("decl. ", ""),
		};
	}

	function rank(values, value) {
		const index = values.indexOf(value);
		return index === -1 ? values.length : index;
	}

	function compareCells(a, b) {
		const left = analysisOf(a);
		const right = analysisOf(b);
		return rank(CASUS_ORDER, left.casus) - rank(CASUS_ORDER, right.casus)
			|| rank(DECLINATIO_ORDER, left.declinatio) - rank(DECLINATIO_ORDER, right.declinatio)
			|| rank(NUMERUS_ORDER, left.numerus) - rank(NUMERUS_ORDER, right.numerus);
	}

	const counts = {};
	document.querySelectorAll(CELL_SELECTOR).forEach((cell) => {
		for (const ending of desinentiae(cell)) {
			counts[ending] = (counts[ending] || 0) + 1;
		}
	});

	const tip = document.createElement("div");
	tip.className = TIP_CLASS;
	tip.id = 'desinentia-tip';
	tip.lang = 'pt-BR';
	tip.role = 'tooltip';
	document.body.appendChild(tip);

	function clear() {
		document.querySelectorAll(`.${MATCH_CLASS}`).forEach((cell) => {
			cell.classList.remove(MATCH_CLASS);
		});
		tip.style.display = "none";
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

		const parts = [];
		for (const ending of reference) {
			parts.push(`-${ending}: ${counts[ending] || 0}x`);
		}
		const cells = Array.from(document.querySelectorAll(CELL_SELECTOR))
			.filter((cell) => cell.dataset.analysis && sharesEnding(reference, desinentiae(cell)))
			.sort(compareCells);
		for (const cell of cells) {
			const forms = cell.dataset.desinentiae.split(/\s+/)
				.filter((form) => reference.has(normalize(form)))
				.map((form) => `-${form}`).join(' / ');
			parts.push(`${forms} — ${cell.dataset.analysis}`);
		}
		tip.textContent = parts.join("\n");
		tip.style.display = "block";
	}

	document.querySelectorAll(CELL_SELECTOR).forEach((cell) => {
		cell.setAttribute('aria-describedby', tip.id);
		cell.addEventListener("mouseenter", (event) => {
			highlight(cell, event);
		});
		cell.addEventListener('focus', () => highlight(cell));
		cell.addEventListener('click', () => highlight(cell));
		cell.addEventListener('blur', clear);
		cell.addEventListener('keydown', (event) => {
			if (event.key === 'Escape') clear();
		});
	});

	document.querySelectorAll("table").forEach((table) => {
		table.addEventListener("mouseleave", (event) => {
			if (event.relatedTarget !== tip) clear();
		});
	});
	tip.addEventListener('mouseleave', clear);
})();
