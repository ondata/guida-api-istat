#!/bin/bash

##############################################################
# Test di validazione della sezione Troubleshooting
# Verifica che tutti i problemi comuni siano documentati
##############################################################

set -euo pipefail

echo "========================================"
echo "Validazione sezione Troubleshooting"
echo "========================================"

# Verifica che la sezione esista
if grep -q "## 🔧 Troubleshooting" README.md; then
    echo "✓ Sezione Troubleshooting presente"
else
    echo "✗ Sezione Troubleshooting NON trovata"
    exit 1
fi

# Verifica presenza sottosezioni
errors_to_check=(
    "Errore 413"
    "Errore 414"
    "Errore 400"
    "Errore 406"
    "Timeout o lentezza"
    "Dati vuoti"
    "Errore SSL"
    "Bug.*endPeriod"
    "Come ottenere aiuto"
)

echo ""
echo "Controllo completezza sezioni:"
all_present=true

for error in "${errors_to_check[@]}"; do
    if grep -q "${error}" README.md; then
        echo "  ✓ ${error}"
    else
        echo "  ✗ ${error} - MANCANTE"
        all_present=false
    fi
done

# Verifica che ci siano esempi di codice
code_blocks=$(grep -c '```bash' README.md || true)
echo ""
echo "Blocchi di codice bash: ${code_blocks}"

if [ ${code_blocks} -gt 100 ]; then
    echo "✓ Presenza adeguata di esempi di codice"
else
    echo "⚠ Pochi esempi di codice (attesi almeno 100)"
fi

# Verifica link TOC
echo ""
echo "Controllo link nel TOC:"
if grep -q "\[🔧 Troubleshooting\]" README.md; then
    echo "  ✓ Link Troubleshooting nel TOC"
else
    echo "  ✗ Link Troubleshooting NON trovato nel TOC"
    all_present=false
fi

# Sommario finale
echo ""
echo "========================================"
if [ "${all_present}" = true ]; then
    echo "✓ VALIDAZIONE COMPLETATA CON SUCCESSO"
    exit 0
else
    echo "✗ VALIDAZIONE FALLITA - Controllare output sopra"
    exit 1
fi
