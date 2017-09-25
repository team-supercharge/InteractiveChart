# Interactive Chart Demo iOS

This demo application is created to demostrate how easy is to make complex/dynamic charts without any libraries or hard work

## How the demo is working
it's a goal saving tracker chart. 
On the left side we can see the transactions we made (deposits, whitdrawals)
On the right side we can see an estimation about how much money we should deposit pay recurringly to reach our goal.

The **chart** is builds up from the following components:

* Estimatated amount line
* Target amount line
* Optimal amount line (dashed) + the required amount for this.
* Transaction tracking (left side)
* Estimation (right side)
* Gradient overlays with legends

And the **sliders**

* Deposit amount (recurring payment amount) 
* Target date (the deadline of the saving)

you can tap on a chart to test the **interaction**

* the **rectangels** with different colors will set the main color of the chartView

## InteractiveChartView
This class is a custom **UIView** that can draw the chart.

we can refresh / draw with it's **drawChart** method




