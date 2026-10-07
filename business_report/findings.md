# E-Commerce Profitability & Customer Intelligence: Findings

Management asked where the business makes money, where it loses it, and who its best customers are. This is what the data says, in the order I'd explain it to a manager.

All amounts are in rupees (₹). One crore is 10 million, and one lakh is 100,000.

---

## The short version

1. **We make a 6% margin overall, and that hides a lot.** Fashion and Beauty earn almost all the profit. Home & Furniture and Grocery lose money.
2. **Discounts above 20% lose money in every category.** Orders discounted 30% or more are 17% of revenue and lose about ₹2.1 crore.
3. **Four sub-categories lose money (Sofas, Laptops, Tables, Staples), and together they make up 62% of revenue.** Laptops lose money even at low discounts, so that is a pricing problem.
4. **About 11% of revenue is refunded.** Fashion and Cash on Delivery orders are returned most often.
5. **A quarter of customers (the Champions) bring 58% of revenue.** Another 15% are proven buyers who have gone quiet for about nine months and are worth winning back.

---

## 1. The business at a glance

| Metric | Value |
|---|---|
| Revenue | ₹56.75 crore |
| Profit | ₹3.43 crore |
| Profit margin | 6.0% |
| Orders | 69,840 |
| Customers | 8,641 |
| Average order value | ₹8,126 |
| Return rate | 12.1% of order lines |
| Revenue refunded through returns | ₹6.31 crore (11.1% of revenue) |

Sales climb every October to December, which looks like festive-season demand. Margin stays between roughly 5% and 7% most months.

---

## 2. Where the money is made and lost

### Category: revenue is not the same as profit

| Category | Share of revenue | Share of profit | Margin |
|---|---|---|---|
| Electronics | 56.9% | 22.1% | 2.4% |
| Fashion | 14.6% | 68.1% | 28.2% |
| Beauty | 2.7% | 21.0% | 46.9% |
| Home & Furniture | 23.7% | -10.3% | -2.6% |
| Grocery | 2.2% | -0.9% | -2.6% |

Electronics is more than half of our sales but barely makes money. Fashion is 15% of sales and produces two thirds of the profit. Furniture and Grocery cost us money on every rupee sold, so growing them makes the loss bigger.

**What I'd do:** point marketing spend at Fashion and Beauty, and fix pricing in Electronics and Furniture before putting more money into growing them.

### Sub-category: the loss is concentrated in four places

| Sub-category | Revenue | Profit | Margin | Average discount |
|---|---|---|---|---|
| Sofas | ₹8.57 crore | -₹47.6 lakh | -5.6% | 20.7% |
| Laptops | ₹22.03 crore | -₹37.3 lakh | -1.7% | 10.7% |
| Tables | ₹4.17 crore | -₹10.3 lakh | -2.5% | 21.3% |
| Staples | ₹0.69 crore | -₹3.3 lakh | -4.8% | 6.6% |

Together they lose about ₹98.6 lakh, on roughly 62% of all revenue.

Two details matter here. First, Laptops lose money with an average discount of only 10.7%, so discounting isn't the main cause. The selling price is too low for what the product costs us. Second, the ten worst individual products are all Laptops or Sofas, but each loses only ₹3–8 lakh. The problem is spread across the whole sub-category, so removing a few products won't fix it.

**What I'd do:** compare Laptop and Sofa prices against supplier cost, and set a minimum margin for these sub-categories.

### Geography matters much less

Margins are about 6% in every region except Northeast (4.2%). Assam (4.2%) and Odisha (4.4%) have the lowest state margins. Bihar has equally slow delivery but a normal margin (6.1%), so I wouldn't blame delivery time for the low margins. Category mix is a far bigger factor than location.

---

## 3. Discounts

Margin falls steadily as the discount rises:

| Discount | Margin |
|---|---|
| None | 16.9% |
| 1–10% | 12.3% |
| 11–20% | 4.3% |
| 21–30% | -10.1% |
| Above 30% | -35.3% |

The break-even point is around a 20% discount. Orders discounted 30% or more are 17.1% of revenue (₹9.70 crore) but lose ₹2.13 crore. Total profit is ₹3.43 crore, so if those orders had simply broken even, profit would have been around ₹5.56 crore. That is an upper bound, because some of those customers wouldn't have bought at a smaller discount.

I checked whether this was just a product-mix effect (loss-making products getting the biggest discounts). It isn't. The same pattern shows up inside every category:

| Category | Margin at 10% discount or less | Margin at 30% discount or more |
|---|---|---|
| Grocery | 1.1% | -53.9% |
| Electronics | 9.8% | -36.9% |
| Home & Furniture | 15.0% | -29.2% |
| Fashion | 39.9% | 7.7% |
| Beauty | 51.4% | 27.4% |

Fashion and Beauty can absorb deep discounts and stay profitable. The other three cannot. A single company-wide discount rule is too blunt.

**What I'd do:** cap discounts at 20% and require approval above that. Then set tighter limits by category: roughly 10% for Grocery and Electronics, and looser ones for Fashion and Beauty.

---

## 4. Shipping and returns

### Shipping is what sinks Grocery

| Category | Shipping cost as % of sales |
|---|---|
| Grocery | 20.4% |
| Beauty | 8.4% |
| Fashion | 3.6% |
| Home & Furniture | 0.8% |
| Electronics | 0.6% |

Grocery orders are small, so delivery eats the margin.

**What I'd do:** a minimum order value or free-shipping threshold, or bundling Grocery with other categories.

### Returns

| Category | Return rate | Revenue returned |
|---|---|---|
| Fashion | 26.2% | ₹2.12 crore |
| Home & Furniture | 11.6% | ₹1.53 crore |
| Electronics | 8.1% | ₹2.53 crore |
| Beauty | 6.9% | ₹10.9 lakh |
| Grocery | 1.3% | ₹1.7 lakh |

| Payment mode | Return rate |
|---|---|
| Cash on Delivery | 16.5% |
| Credit Card | 10.4% |
| UPI | 10.1% |
| Net Banking | 9.9% |
| Debit Card | 9.6% |

Fashion has the highest return rate, but Electronics returns the most money because each order is worth more. Cash on Delivery orders come back about 60% more often than prepaid ones. Note that the profit figures in this analysis are calculated before returns, so true profit is lower than what I report.

**What I'd do:** better size guides and photos in Fashion, and a small incentive for paying upfront.

---

## 5. Customers

I defined a customer as **churned** if they hadn't ordered in the last 90 days of the data. For segmentation I scored every customer from 1 to 5 on how recently they bought, how often, and how much (RFM), then grouped them.

### A loyal core carries the business

| Customer type | Customers | Share of revenue | Average profit per customer |
|---|---|---|---|
| Repeat (2+ orders) | 6,915 (80%) | 97.5% | ₹4,826 |
| One-time | 1,726 (20%) | 2.5% | ₹552 |

The top 20% of customers produce 64% of revenue and 57% of profit. A repeat customer is worth roughly nine times a one-time buyer in profit.

### Segments

| Segment | Customers | Share of revenue | Average profit per customer | Days since last order |
|---|---|---|---|---|
| Champions | 2,172 (25%) | 57.7% | ₹9,188 | 17 |
| Loyal | 1,716 (20%) | 20.2% | ₹3,705 | 53 |
| At risk | 1,296 (15%) | 15.3% | ₹3,862 | 281 |
| New / promising | 658 (8%) | 1.2% | ₹838 | 23 |
| Low value / lost | 2,799 (32%) | 5.5% | ₹876 | 265 |

Champions are a quarter of customers and earn about 2.5 times the profit of a Loyal customer. The **At risk** group is the best opportunity: 1,296 customers who each placed about eight orders, then went quiet for roughly nine months. They represent ₹8.69 crore of past revenue and about ₹50 lakh of past profit.

**What I'd do:** reward Champions with early access and perks, and run a win-back campaign for At risk customers first. Keep the offer inside the 20% discount cap.

### Churn

Overall churn is 43.9% (3,794 of 8,641 customers). Two patterns stand out.

**Slow delivery goes with higher churn.** Comparing customers with five or more orders:

| Average delivery time | Churn rate |
|---|---|
| 3 days or less | 22.5% |
| 3–5 days | 26.1% |
| Over 5 days | 31.1% |

Assam (59.7%), Bihar (50.2%) and Odisha (49.4%) have the highest churn, and they are also the slowest states to deliver to. The link isn't perfect, though. Telangana has fast delivery (2.6 days) and still loses 46.1%, so delivery is one factor among several.

**Most customers are lost early.**

| Orders placed | Churn rate |
|---|---|
| 1 order | 76.0% |
| 2–4 orders | 53.2% |
| 5–9 orders | 34.1% |
| 10+ orders | 16.8% |

Three in four first-time buyers never come back. Part of this pattern is mechanical, because someone with 40 orders had more chances to buy recently, so I read it as "the first month matters" and don't treat it as proof that a second order prevents churn.

I also looked at returns and churn. Once order count was taken into account there was no clear link, so I don't treat returns as a driver of churn.

**What I'd do:** send a follow-up offer within 30 days of a first order, and improve delivery in Assam, Bihar and Odisha before spending on marketing there.

---

## 6. What I couldn't explain

**The October 2025 margin dip.** Margin fell to 4.6%, the lowest month, while revenue rose 35%. I checked the obvious causes. The average discount was 14.2%, the same as other months, and Laptops and Sofas were only slightly a bigger share of sales (55.9% against 53–55% nearby). Neither explains the drop, so I'm leaving it as an open question and not guessing at a cause.

---

## 7. Recommendations, in priority order

| Priority | Action | Why |
|---|---|---|
| 1 | Cap discounts at 20%, with tighter category limits | Deep discounts lose about ₹2.1 crore |
| 2 | Review pricing and cost for Laptops, Sofas and Tables | They lose money on 62% of revenue |
| 3 | Win back At risk customers | About ₹8.7 crore of past revenue from proven buyers |
| 4 | Shift marketing to Fashion and Beauty | They earn 89% of profit |
| 5 | Add a minimum order or free-shipping threshold for Grocery | Shipping is 20% of Grocery sales |
| 6 | Cut Fashion returns and encourage prepaid payment | 11% of revenue is refunded |
| 7 | Follow up within 30 days of a first order | 76% of one-time buyers never return |
| 8 | Improve delivery in Assam, Bihar and Odisha | Highest churn, slowest delivery |

---

## 8. About this analysis

- **Data:** synthetic e-commerce data for India, 2024–2025, created to simulate a real business. Churn levels and other figures are illustrative and shouldn't be read as real-world benchmarks.
- **Process:** cleaned in Python (duplicates, inconsistent spelling, negative values and missing values), loaded into MySQL, and analysed with SQL. The dashboard is built in Power BI.
- **Size:** 97,673 order lines, 69,840 orders, 8,641 customers and 350 products.
- **Limits:** profit is measured before returns. Churn depends on the 90-day window I chose. Where two things move together (delivery time and churn), this analysis shows an association, not proof of cause.