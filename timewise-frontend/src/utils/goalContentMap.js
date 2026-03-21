/**
 * Same logic as backend `services/recommender.py` GOAL_CONTENT_MAP (content_type → goal).
 */

export const GOAL_CONTENT_MAP = {
  learn: new Set(["article", "video", "book_summary", "tutorial", "quiz"]),
  focus: new Set(["flashcard", "exercise", "tutorial"]),
  relax: new Set([
    "video",
    "podcast",
    "music_playlist",
    "documentary",
    "exercise",
    "journaling",
  ]),
  productive: new Set(["article", "podcast", "tutorial", "quiz"]),
};

const GOAL_ORDER = ["learn", "focus", "relax", "productive"];

export function contentMatchesGoal(contentType, goal) {
  if (!goal || !contentType) return true;
  return GOAL_CONTENT_MAP[goal]?.has(contentType) ?? false;
}

/** Which focus modes match this content type (ordered). */
export function goalsForContentType(contentType) {
  if (!contentType) return [];
  return GOAL_ORDER.filter((g) => GOAL_CONTENT_MAP[g].has(contentType));
}
