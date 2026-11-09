# Cancel Mitigation: Hotel Bookings

**Tools:** SQL (MySQL), Power BI
**Dataset:** [Hotel Booking Demand (Kaggle)](https://www.kaggle.com/datasets/jessemostipak/hotel-booking-demand), 119,390 bookings from a city hotel and a resort hotel

## 📌 Summary

37% of bookings are cancelled and an estimated 16.7M in revenue lost. Risk rises steadily with lead time. Bookings made more than 90 days ahead are 43% of all bookings but 59% of all cancellations. Groups and travel agents book earliest and cancel most, but the agent gap largely disappears once lead time is accounted for, while a handful of agents stand out. Two patterns found in SQL (Non Refund deposits and "1 prior cancellation") cancel at 94% to 99%, so it is flagged for investigation rather than build policy on them.

## ❓ Business Question

Hotels plan staffing, pricing and inventory around expected stays, so cancellations hurt forecasting and revenue. The dashboard answers three questions: **who cancels, when are they high risk, and what does it cost?**

## 🖥️ Dashboard

![Dashboard](dashboard/hotel_booking_dashboard.png)

## 📊 Headline Metrics

| Metric | Value | SQL basis |
|---|---|---|
| Total bookings | 119,390 | `COUNT(*)` |
| Total cancellations | 44,224 | `SUM(is_canceled)` |
| Cancellation rate | 37.04% | `AVG(is_canceled)` |
| Revenue lost | ~16.7M | ADR × nights for cancelled bookings with ADR > 0 (44,011 bookings) |

*Revenue lost is an estimate. It ignores cancellation fees and rebooking*

## 🔍 Findings

### 1. When are bookings high risk? Lead time

Lead time is the number of days between booking and arrival. Cancellation rate by lead-time band:

| Lead time | Bookings | Cancellations | Cancel rate |
|---|---|---|---|
| Same day | 6,345 | 430 | 6.78% |
| 1-30 days | 32,361 | 6,755 | 20.87% |
| 31-90 days | 29,553 | 11,141 | 37.70% |
| 91-180 days | 26,439 | 11,821 | 44.71% |
| 181-365 days | 21,544 | 11,947 | 55.45% |
| 365+ days | 3,148 | 2,130 | 67.66% |

Risk rises gradually rather than at a single cliff. It reaches the overall average (37%) in the 31-90 day band and passes 50% beyond 180 days. **90 days** is used as a practical cutoff. Bookings made more than 90 days ahead are 51,131 bookings (43% of the total) and account for 25,898 cancellations (59% of all cancellations), a cancellation rate of 50.7%.

### 2. Who cancels? Market segment

| Market segment | Bookings | Avg lead time (days) | Cancel rate |
|---|---|---|---|
| Groups | 19,811 | 187 | 61.06% |
| Online TA | 56,477 | 83 | 36.72% |
| Offline TA/TO | 24,219 | 135 | 34.32% |
| Aviation | 237 | 4 | 21.94% |
| Corporate | 5,295 | 22 | 18.73% |
| Direct | 12,606 | 50 | 15.34% |
| Complementary | 743 | 13 | 13.06% |

Groups combine the longest lead time with the highest cancellation rate, which makes them the clearest high-risk segment. Online TA has the largest volume and cancels close to the overall average. Corporate and Direct book close to arrival and rarely cancel. Lead time is not the whole story: Offline TA/TO books 135 days ahead but cancels slightly below average.

### 3. Travel agents vs direct bookings

Here "Direct" means a booking with no agent listed (not the Direct market segment above).

Overall, agent bookings cancel more (39.00% vs 24.66%) and are booked much earlier (avg 112 vs 56 days). Splitting by lead-time band shows why:

| Lead time | Direct bookings | Direct cancel rate | Agent bookings | Agent cancel rate |
|---|---|---|---|---|
| 0-30 days | 10,251 | 12.46% | 28,455 | 20.76% |
| 31-90 days | 2,381 | 36.58% | 27,172 | 37.80% |
| 90+ days | 3,708 | 50.76% | 47,423 | 50.64% |

46% of agent bookings are made more than 90 days ahead, versus 23% of direct bookings. At 90+ days the two channels cancel at the same rate, so the agent gap is largely a lead-time mix effect rather than an agent effect. Company bookings show the same pattern: 17.52% cancel (avg lead 49 days) vs 38.22% for bookings without a company (107 days).

### 4. Which agents stand out?

Agents with more than 500 bookings, ranked by cancellation rate (top 5):

| Agent | Bookings | Avg lead time (days) | Cancel rate |
|---|---|---|---|
| 29 | 683 | 137 | 79.94% |
| 19 | 1,061 | 143 | 73.52% |
| 1 | 7,191 | 244 | 73.43% |
| 20 | 540 | 154 | 66.48% |
| 229 | 786 | 395 | 61.58% |

All five have long average lead times, so lead time and agent behaviour overlap. Agent 1 has the largest volume.

### 5. Other SQL findings (not shown on the dashboard)

**Non Refund deposits cancel 99.36% of the time** (14,587 bookings), versus 28.38% for No Deposit (104,641) and 22.22% for Refundable (162). A paid, non-refundable booking should not be the most cancelled, so this is probably an artefact of how the booking system records these reservations (for example no-shows or modified bookings logged as cancellations). This is a hypothesis to verify, not a finding. If it is true, the revenue lost figure above would include money the hotel actually kept.

**Bookings with one prior cancellation cancel 94.43% of the time** (6,051 bookings), but with 2+ prior cancellations the rate falls to 52.66%, so it is not a simple "more past cancellations, more risk" pattern. 5,396 of the 6,051 bookings came via agents and 99.31% of those cancelled, while direct bookings with one prior cancellation cancel 54.20% (655 bookings). The effect looks concentrated in one group of agent bookings, so I do not treat it as proof of guest behaviour.

## 💡 Recommendations

1. **Test deposits or reconfirmation for bookings made more than 90 days ahead.** This is 43% of bookings and 59% of cancellations. Run it as a test and measure the change in cancellations.
2. **Set cancellation terms by lead time and channel**, not by "agent" in general. Focus on Groups (61% cancel) and review the five high-risk agents above (62% to 80%).
3. **Investigate the Non Refund and 1-prior-cancellation patterns** before building rules on them, for example by checking how `reservation_status` splits within each group.

## ⚠️ Limitations

- Findings are correlations. Lead time, segment, deposit type and agent overlap heavily, so each effect is not independent of the others.
- Revenue lost = ADR × nights for cancelled bookings. It ignores cancellation fees and rebooking, and currency is not stated.
- Bookings with ADR of 0 or below (a few negative values) were excluded from the revenue calculation.
- No cost data, so the profit impact of any policy cannot be assessed.

## 🗂️ SQL Queries

| Query | Question it answers |
|---|---|
| Cancellation rate | How many bookings are cancelled overall? |
| Lead-time buckets | How does risk change with lead time? |
| Deposit type, market segment, prior cancellations | Which factors are linked to cancellation? |
| Agent vs direct (overall, and by lead-time band) | Do agents really cancel more, or do they just book earlier? |
| Top agents (500+ bookings) | Which agents have the highest cancellation rates? |
| Revenue lost | What do cancellations cost? |
| Lead time by market segment | What drives long lead times? |

## 🚀 How to Replicate

1. Load `hotel_bookings.csv` into MySQL (table `hotel_bookings`).
2. Run `sql/hotel_analysis.sql` to generate the aggregations above.
3. Open `dashboard/hotel_booking_dashboard.pbix` in Power BI Desktop. If `adr` fails to convert to a decimal, set the import locale to English (United States).
