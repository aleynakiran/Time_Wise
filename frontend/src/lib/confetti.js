import confetti from "canvas-confetti";

const palette = ["#58cc02", "#1cb0f6", "#ffd66e", "#7c6cfc", "#ff8f8f", "#ffffff"];

/**
 * Full-screen confetti burst (theme-aligned greens / blues / gold).
 */
export function fireConfettiBurst() {
  const fire = (opts) =>
    confetti({
      ticks: 320,
      gravity: 1.05,
      decay: 0.92,
      colors: palette,
      ...opts,
    });

  fire({ particleCount: 110, spread: 88, startVelocity: 38, origin: { x: 0.5, y: 0.58 } });
  fire({ particleCount: 60, spread: 120, startVelocity: 32, origin: { x: 0.15, y: 0.72 } });
  fire({ particleCount: 60, spread: 120, startVelocity: 32, origin: { x: 0.85, y: 0.72 } });

  setTimeout(() => {
    fire({ particleCount: 70, spread: 100, startVelocity: 28, origin: { x: 0.5, y: 0.62 }, scalar: 0.9 });
  }, 180);
}
