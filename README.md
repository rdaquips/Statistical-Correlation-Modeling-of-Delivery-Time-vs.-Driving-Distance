### [1]. Raw File (CSV)

### [2]. Database & Feature Engineering (SQL)
* **Data Cleaning & Imputation:**
  * Handled skewed distribution of distance metrics using window function median imputations (`PERCENTILE_CONT(0.5)` partitioned by `delivery_service_level`).
  * Converted timestamp deltas into exact minute intervals using floating-point conversions multiplied by $1,440.0$.
* **Status Normalization:**
  * Categorized edge cases (e.g., null statuses with complete delivery timestamps, cancelled tags with physical deliveries).
  * Converted delivery service levels into explicit categories: `Early`, `On Time`, `Late`, and `Untagged`.
* **Stage Tracking:**
  * Created boolean stage counters (`stage_0` through `stage_3`) evaluating completed and untagged orders across fulfillment checkpoints (`Placed` $\rightarrow$ `Prepared` $\rightarrow$ `Picked Up` $\rightarrow$ `Delivered`).

### [3]. Business Intelligence & Statistical Modeling (Power BI)
* **Scatter Plots & Trendlines:** Visualized relationship density and calculated Pearson correlation coefficients ($R$) between driving distances and completion durations.
* **Fulfillment Funnel:** Constructed a multi-stage cancellation tracking to isolate revenue leakage points.
* **Real-Time Operations Dashboard:** Built executive KPIs for service times, fulfillment performance distribution, and order volume.

### [4]. Report (PDF File)
This project analyzes **16,842 logistics orders** from ABC Inc. to evaluate delivery fulfillment performance, identify operational bottlenecks, and model statistical relationships between driving distance and service time. 

By executing robust **SQL** transformations (data cleaning, median imputation, and time-interval feature engineering) and building interactive **Power BI** scatter plots and fulfillment funnels, the study revealed that **pickup delays—not physical distance—are the primary driver of late deliveries.**

Key Insights & Analytics Summary

1. **Fulfillment Breakdown:**
   * Total Orders: **16,842**
   * Completed: **14,276 (84.76%)** | Cancelled: **2,566 (15.24%)**
   * On-Time Deliveries: **7,906** | Late Deliveries: **5,396** | Early Deliveries: **902**
2. **The Pickup Bottleneck:**
   * For late orders, the median **Total Service Time reached 106.58 minutes**.
   * **>65% of total delay** occurred during the pickup phase alone (median pickup duration of **71.34 minutes**).
3. **Distance vs. Service Time Disconnect (Statistical Correlation):**
   * **Total Service Time vs. Total Distance:** Weak correlation ($R = 0.22$).
   * **Pickup Duration vs. Rider-to-Store Distance:** Virtually no correlation ($R = 0.05$).
   * **Delivery Duration vs. Store-to-Customer Distance:** Moderate correlation ($R = 0.39$).
   * *Takeaway:* Delays are heavily driven by operational inefficiencies (e.g., rider dispatching, store preparation lags) rather than geographical distance.
4. **Cancellation Funnel & Sunk Costs:**
   * **Stage 0 (Placed & Cancelled):** 2,522 orders
   * **Stage 1 (Prepared & Cancelled):** 40 orders *(Direct loss of ingredients/labor)*
   * **Stage 2 (Picked Up & Cancelled):** 4 orders *(Sunk costs in transit, fuel, and labor)*
