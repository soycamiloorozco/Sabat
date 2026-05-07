# SleepCycle Algorithm Analysis — Sabat SmartAlarm Reference

## How SleepCycle Works

SleepCycle uses **two complementary detection methods**:

### 1. Microphone (Sound Detection) — Most Accurate
- Places phone near the bed
- Microphone listens to breathing, movement, snoring, coughing
- Patented sound detection algorithm analyzes audio patterns
- Correlates with habits and environmental factors
- Provides comprehensive sleep health picture

### 2. Accelerometer + Microphone (Motion Detection)
- Uses phone/watch accelerometer to detect physical movement
- **High movement = Light sleep phase** (body shifts, turns, adjusts)
- **Low movement / stillness = Deep sleep phase** (paralysis during REM, minimal deep sleep movement)
- Smart alarm only fires during light sleep within the wake-up window

## Sleep Phase Logic

| Phase | Accelerometer Signature | Movement Level |
|-------|------------------------|----------------|
| Awake | High variance, frequent spikes | Lots of movement |
| Light | Moderate variance, intermittent | Occasional shifts |
| REM | Very low variance (muscle atonia) | Minimal to none |
| Deep | Low variance, sustained stillness | Minimal |

## Smart Alarm Window
- User sets target wake time (e.g., 7:00 AM)
- Configurable window (default 30 min, e.g., 6:30–7:00 AM)
- Alarm fires at optimal light-sleep moment within window
- Hard guarantee alarm at target time if no light phase detected

## Key Algorithmic Insights

1. **Variance-based classification**: SleepCycle uses statistical variance of accelerometer readings over sliding windows, not instantaneous magnitude
2. **Circadian rhythm correlation**: Long-term patterns improve accuracy
3. **Environmental adaptation**: Noise, temperature, and other factors are correlated
4. **Machine learning**: Modern versions use ML to improve phase prediction

## Sabat Current Implementation

`NightTrackerService` currently uses a simple magnitude threshold:
```
magnitude = |x| + |y| + |z|
magnitude >= 1.75  → Awake
magnitude >= 1.35  → Light
magnitude >= 1.1   → REM
magnitude < 1.1    → Deep
```

### Recommended Enhancements
- Switch to **variance-based detection** using rolling window (more accurate)
- Use **5-10Hz sample rate** (currently 5Hz at 0.2s interval) ✅
- Add **circadian phase estimation** based on time since sleep onset
- Add **microphone-based fallback** for sound detection
- Implement **phase transition probability** (REM→Light→Deep cycles ~90 min)
