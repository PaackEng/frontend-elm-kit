import { Chart } from 'chart.js';

type Benchmark = { topic: string; index: number; duration: number };
type Benchmarks = Benchmark[];
type Profiling = { id: string; samples: Benchmarks[] };

const profileApp = (env: {
  profilingId: string;
  profilingSamples: number;
  profilingMessages: number;
}) => {
  const originalConsoleLog = window.console.log;

  const benchmarkRegex = /^profile:\/\/([^\/]+)\/([^\/]+)\/([^:]+): (.*)$/;

  const benchmarksStart: Record<string, number> = {};
  const benchmarks: Benchmarks = [];
  var codeChart: Chart | null = null;
  var viewChart: Chart | null = null;

  var autoProfiling: Profiling | null = null;
  if (env.profilingId !== '') {
    try {
      autoProfiling = JSON.parse(localStorage.profiling);
    } catch (_) {
      autoProfiling = null;
    }
    if (autoProfiling === null || autoProfiling.id !== env.profilingId) {
      alert('Started profiling');
      autoProfiling = { id: env.profilingId, samples: [] };
    }
    if (autoProfiling.samples.length >= env.profilingSamples) {
      autoProfiling = null;
    }
  }

  const chartOptions = {
    responsive: true,
    showLine: true,
  };

  function updateCodeGraph(newData: { x: number; y: number }) {
    if (autoProfiling !== null) return null;
    if (codeChart === null) {
      const node = document.getElementById('code-chart');
      if (!(node instanceof HTMLCanvasElement)) return;
      codeChart = new Chart(node, {
        type: 'scatter',
        data: {
          datasets: [
            {
              label: 'Code timegraph',
              data: [newData],
            },
          ],
        },
        options: chartOptions,
      });
    } else {
      codeChart.data.datasets[0].data.push(newData);
      codeChart.update();
    }
  }

  function updateViewGraph(newData: { x: number; y: number }) {
    if (autoProfiling !== null) return null;
    if (viewChart === null) {
      const node = document.getElementById('view-chart');
      if (!(node instanceof HTMLCanvasElement)) return;
      viewChart = new Chart(node, {
        type: 'scatter',
        data: {
          datasets: [
            {
              label: 'View timegraph',
              data: [newData],
            },
          ],
        },
        options: chartOptions,
      });
    } else {
      viewChart.data.datasets[0].data.push(newData);
      viewChart.update();
    }
  }

  window.console.log = function (message?: any, ...optionalParams: any[]) {
    const benchmarkMatch = message.toString().match(benchmarkRegex);
    if (benchmarkMatch !== null) {
      const now = new Date().getTime();
      const action = benchmarkMatch[1];
      const topic = benchmarkMatch[2];
      const index = parseInt(benchmarkMatch[3]);

      if (action === 'start') {
        benchmarksStart[topic] = now;
      } else if (action === 'end') {
        const duration = now - benchmarksStart[topic];
        benchmarks.push({
          topic,
          index,
          duration,
        });

        const chartData = { x: index, y: duration };
        if (topic === 'code') updateCodeGraph(chartData);
        else if (topic === 'view') updateViewGraph(chartData);

        if (
          autoProfiling !== null &&
          index >= env.profilingMessages &&
          topic === 'view'
        ) {
          autoProfiling.samples.push(benchmarks);
          localStorage.setItem('profiling', JSON.stringify(autoProfiling));
          const samples = autoProfiling.samples.length;
          autoProfiling = null;
          if (samples >= env.profilingSamples) {
            alert('Profiling finished');
          } else window.location.reload();
        }
      }
      return null;
    } else return originalConsoleLog(message, ...optionalParams);
  };

  return { getBenchmarks: () => benchmarks };
};

export { Benchmark, Benchmarks, Profiling, profileApp };
