#  Updating Data

In most table views, we want to be able to update our data after binding. Tableau supports two ways to update data - for those using RxSwift,
binders support the use of binding an Observable along with your cell or header/footer type that the binder will subscribe to to update the
table. If you're not using RxSwift, Tableau provides the ability to create 'update' handlers at the end of your binding chains that you can call
with new data to update the table.

## RxSwift

We'll start with the RxSwift variant. 
