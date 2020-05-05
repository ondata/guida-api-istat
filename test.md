## Esempio vega-lite

<div id="vis" class="vl-responsive"></div>

<script>
  // carica definizione grafico
  const spec = "./esempi/ISTAT_01.json";
  // renderizza grafico
  vegaEmbed('#vis', spec,{theme: "fivethirtyeight"})

</script>
