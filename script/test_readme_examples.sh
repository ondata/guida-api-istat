#!/bin/bash

###################################################################
# Script di test per validare tutti gli esempi presenti nel README
# Verifica che ogni URL documentato funzioni correttamente
###################################################################

set -euo pipefail

# Colori per output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Directory di output per test
test_dir="./tmp/readme_tests"
mkdir -p "${test_dir}"

# Contatori
total_tests=0
passed_tests=0
failed_tests=0

# Funzione di test
test_endpoint() {
    local test_name="${1}"
    local curl_cmd="${2}"
    local expected_check="${3:-HTTP_CODE:200}" # Default: controlla status 200
    
    total_tests=$((total_tests + 1))
    echo -e "\n${YELLOW}[TEST ${total_tests}]${NC} ${test_name}"
    
    # Timeout di 45 secondi per test
    if timeout 45s bash -c "${curl_cmd}" > "${test_dir}/test_${total_tests}.output" 2>&1; then
        # Verifica se l'output contiene la stringa attesa
        if grep -q "${expected_check}" "${test_dir}/test_${total_tests}.output" 2>/dev/null; then
            echo -e "${GREEN}✓ PASSED${NC}"
            passed_tests=$((passed_tests + 1))
            return 0
        fi
    fi
    
    echo -e "${RED}✗ FAILED${NC}"
    echo "   Output salvato in: ${test_dir}/test_${total_tests}.output"
    failed_tests=$((failed_tests + 1))
    return 1
}

echo "=========================================="
echo "TEST SUITE README.md - API ISTAT"
echo "=========================================="

# Test di connettività iniziale
echo -e "\n${YELLOW}[PRECHECK]${NC} Verificando raggiungibilità server ISTAT..."
if timeout 15s curl -kL -s -I "https://esploradati.istat.it/SDMXWS/" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Server ISTAT raggiungibile${NC}"
else
    echo -e "${RED}✗ ERRORE: Server ISTAT non raggiungibile${NC}"
    echo "   Possibili cause:"
    echo "   - Connessione internet non disponibile"
    echo "   - Server ISTAT temporaneamente offline"
    echo "   - Firewall che blocca l'accesso"
    echo ""
    echo "   Verifica manualmente:"
    echo "   curl -I https://esploradati.istat.it"
    echo ""
    exit 1
fi

# ============================================
# SEZIONE: Quick Start Examples
# ============================================
echo -e "\n${YELLOW}=== QUICK START EXAMPLES ===${NC}"

test_endpoint \
    "Esempio 1: Primi 5 record incidenti (CSV)" \
    'curl -kL -s -w "\nHTTP_CODE:%{http_code}" -H "Accept: application/vnd.sdmx.data+csv;version=1.0.0" "https://esploradati.istat.it/SDMXWS/rest/data/41_983?lastNObservations=5"' \
    "HTTP_CODE:200"

test_endpoint \
    "Esempio 2: Lista dataflow XML" \
    'curl -kL -s -w "\nHTTP_CODE:%{http_code}" "https://esploradati.istat.it/SDMXWS/rest/dataflow/IT1" | head -20' \
    "structure:Dataflow"

test_endpoint \
    "Esempio 3: Feriti Palermo ultimi 10 (CSV)" \
    'curl -kL -s -w "\nHTTP_CODE:%{http_code}" -H "Accept: application/vnd.sdmx.data+csv;version=1.0.0" "https://esploradati.istat.it/SDMXWS/rest/data/41_983/A.082053.KILLINJ.F?lastNObservations=10"' \
    "HTTP_CODE:200"

# ============================================
# SEZIONE: Metadati
# ============================================
echo -e "\n${YELLOW}=== METADATI ===${NC}"

test_endpoint \
    "Dataflow IT1 (lista completa)" \
    'curl -kL -s -w "\nHTTP_CODE:%{http_code}" "https://esploradati.istat.it/SDMXWS/rest/dataflow/IT1"' \
    "HTTP_CODE:200"

test_endpoint \
    "Datastructure DCIS_INCIDMORFER_COM" \
    'curl -kL -s -w "\nHTTP_CODE:%{http_code}" "https://esploradati.istat.it/SDMXWS/rest/datastructure/IT1/DCIS_INCIDMORFER_COM/"' \
    "structure:DimensionList"

test_endpoint \
    "Codelist CL_FREQ (frequenze)" \
    'curl -kL -s -w "\nHTTP_CODE:%{http_code}" "https://esploradati.istat.it/SDMXWS/rest/codelist/IT1/CL_FREQ"' \
    "HTTP_CODE:200"

test_endpoint \
    "Availableconstraint dataset 41_983" \
    'curl -kL -s -w "\nHTTP_CODE:%{http_code}" "https://esploradati.istat.it/SDMXWS/rest/availableconstraint/41_983"' \
    "HTTP_CODE:200"

# ============================================
# SEZIONE: Formati output
# ============================================
echo -e "\n${YELLOW}=== FORMATI OUTPUT ===${NC}"

test_endpoint \
    "Formato CSV (primissimi 3 record)" \
    'curl -kL -s -w "\nHTTP_CODE:%{http_code}" -H "Accept: application/vnd.sdmx.data+csv;version=1.0.0" "https://esploradati.istat.it/SDMXWS/rest/data/41_983?firstNObservations=3"' \
    "DATAFLOW"

test_endpoint \
    "Formato JSON semplificato (3 record)" \
    'curl -kL -s -w "\nHTTP_CODE:%{http_code}" -H "Accept: application/json" "https://esploradati.istat.it/SDMXWS/rest/data/41_983?firstNObservations=3"' \
    "dataSets"

test_endpoint \
    "Formato JSON strutture (dataflow 115_333)" \
    'curl -kL -s -w "\nHTTP_CODE:%{http_code}" -H "Accept: application/vnd.sdmx.structure+json;version=1.0" "https://esploradati.istat.it/SDMXWS/rest/dataflow/IT1/115_333/1.0"' \
    "HTTP_CODE:200"

# ============================================
# SEZIONE: Filtri temporali
# ============================================
echo -e "\n${YELLOW}=== FILTRI TEMPORALI ===${NC}"

test_endpoint \
    "Filtro anno (2020, primi 5 record)" \
    'curl -kL -s -w "\nHTTP_CODE:%{http_code}" -H "Accept: application/vnd.sdmx.data+csv;version=1.0.0" "https://esploradati.istat.it/SDMXWS/rest/data/41_983?startPeriod=2020&endPeriod=2020&firstNObservations=5"' \
    "HTTP_CODE:200"

# ============================================
# SEZIONE: Parametri di limitazione
# ============================================
echo -e "\n${YELLOW}=== PARAMETRI LIMITAZIONE ===${NC}"

test_endpoint \
    "firstNObservations=10" \
    'curl -kL -s -w "\nHTTP_CODE:%{http_code}" -H "Accept: application/vnd.sdmx.data+csv;version=1.0.0" "https://esploradati.istat.it/SDMXWS/rest/data/41_983?firstNObservations=10"' \
    "HTTP_CODE:200"

test_endpoint \
    "lastNObservations=5" \
    'curl -kL -s -w "\nHTTP_CODE:%{http_code}" -H "Accept: application/vnd.sdmx.data+csv;version=1.0.0" "https://esploradati.istat.it/SDMXWS/rest/data/41_983?lastNObservations=5"' \
    "HTTP_CODE:200"

test_endpoint \
    "detail=serieskeysonly (solo chiavi)" \
    'curl -kL -s -w "\nHTTP_CODE:%{http_code}" "https://esploradati.istat.it/SDMXWS/rest/data/41_983?detail=serieskeysonly&firstNObservations=10"' \
    "HTTP_CODE:200"

# ============================================
# SEZIONE: Filtri dimensionali
# ============================================
echo -e "\n${YELLOW}=== FILTRI DIMENSIONALI ===${NC}"

test_endpoint \
    "Filtro Palermo feriti (A.082053.KILLINJ.F)" \
    'curl -kL -s -w "\nHTTP_CODE:%{http_code}" -H "Accept: application/vnd.sdmx.data+csv;version=1.0.0" "https://esploradati.istat.it/SDMXWS/rest/data/41_983/A.082053.KILLINJ.F?lastNObservations=5"' \
    "HTTP_CODE:200"

test_endpoint \
    "Filtro OR multiplo (Palermo+Bari)" \
    'curl -kL -s -w "\nHTTP_CODE:%{http_code}" -H "Accept: application/vnd.sdmx.data+csv;version=1.0.0" "https://esploradati.istat.it/SDMXWS/rest/data/41_983/A.082053+072006.KILLINJ.F?lastNObservations=3"' \
    "HTTP_CODE:200"

# ============================================
# REPORT FINALE
# ============================================
echo -e "\n=========================================="
echo "RISULTATI TEST"
echo "=========================================="
echo -e "Totale test:   ${total_tests}"
echo -e "${GREEN}Superati:      ${passed_tests}${NC}"
echo -e "${RED}Falliti:       ${failed_tests}${NC}"

if [ ${failed_tests} -eq 0 ]; then
    echo -e "\n${GREEN}✓ TUTTI I TEST SUPERATI${NC}"
    exit 0
else
    echo -e "\n${RED}✗ ALCUNI TEST FALLITI${NC}"
    echo "Controlla i file di output in: ${test_dir}/"
    exit 1
fi
