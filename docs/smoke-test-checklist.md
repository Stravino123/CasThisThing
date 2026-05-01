# Manual Smoke Test Checklist

Run on iPhone simulator (iPhone 17, iOS 26) after each build.

---

## 1. Empty state
- [ ] Launch app → see "Nessuna sessione" empty state with drop icon

## 2. Create session
- [ ] Tap **+** → new row "Nuova sessione" appears in "In corso" section
- [ ] Row shows "step 1/4" and 1 filled dot out of 4

## 3. Rename session
- [ ] Open session → tap **Rinomina** → enter "Anelli estate 2025" → Salva
- [ ] Navigation title updates; back in list the new name is shown
- [ ] Try saving blank title → title must NOT change

## 4. Workflow step unlock (wax weight — step 1)
- [ ] Step 1 row is a `DisclosureGroup` → tap to expand → enter 12.5 g → collapse
- [ ] Step 2 row becomes editable (DisclosureGroup), steps 3–4 remain locked (no disclosure)

## 5. Workflow steps 2–4
- [ ] Enter silverNeeded (step 2) → step 3 unlocks
- [ ] Enter silverCost €132 (step 3) → step 4 unlocks; row shows "step 3/4" in list
- [ ] Enter castingCost €115 (step 4) → session moves to "Completate"; list row shows total cost

## 6. Add lavorazione (new, before session complete)
- [ ] Tap **Aggiungi lavorazione** → form opens
- [ ] Phase indicator shows step 3 as current (silverCost filled, castingCost not)
- [ ] Enter label "Anello" + wax weight 4.2 g → Salva
- [ ] Lavorazione row shows label and "argento — da pesare"
- [ ] Cost column shows "— €" (session not complete)

## 7. Edit lavorazione (before session complete)
- [ ] Tap existing lavorazione row → form opens in edit mode
- [ ] Silver weight field shows lock icon "sbloccato dopo step 4"
- [ ] Change label → Salva → row updates

## 8. Lavorazione silver weight (after session complete)
- [ ] Add a second lavorazione "Ciondolo", wax 2.1 g
- [ ] Complete the session (enter all 4 steps)
- [ ] Reopen "Anello" → silver weight field now editable → enter 14.2 g → Salva
- [ ] Reopen "Ciondolo" → enter 19.8 g → Salva
- [ ] Both lavorazione rows show euro costs
- [ ] Header shows total silver weight (14.2 + 19.8 = 34.0 g)
- [ ] Cost summary section visible with correct total (€132 + €115 = €247)
- [ ] "Anello" cost ≈ (14.2/34.0) × 247 ≈ €103.08
- [ ] "Ciondolo" cost ≈ (19.8/34.0) × 247 ≈ €143.92

## 9. Add lavorazione when session already complete
- [ ] Tap **Aggiungi lavorazione** with completed session
- [ ] Silver weight field is unlocked and editable
- [ ] Enter label "Bracciale", wax 3.0 g, silver 10.0 g → Salva
- [ ] All three pieces now show recalculated costs summing to €247

## 10. Delete lavorazione
- [ ] Swipe-to-delete on a lavorazione row → confirm it disappears
- [ ] Or open lavorazione → tap "Elimina lavorazione" → dismissed, row gone
- [ ] Remaining pieces' costs update (total silver weight changes)

## 11. Delete session
- [ ] Swipe-to-delete on a session → session disappears from list
- [ ] If last session deleted → empty state returns

## 12. Keyboard dismiss
- [ ] Tap a numeric field in the workflow section → decimal keyboard appears
- [ ] Tap **Fine** in keyboard toolbar → keyboard dismisses

---

*All unit tests (18/18) also run via `xcodebuild test` before release.*
