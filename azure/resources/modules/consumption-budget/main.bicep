targetScope = 'subscription'

param name string
param amount int
param timeGrain string
param startdate string = utcNow('yyyy-MM-01')
param firstThreshold int
param secondThreshold int
param contactEmails array


module budget 'modules/consumption-budget.bicep' = {
  name: name
  params: {
    name: name
    amount: amount
    timeGrain: timeGrain
    startDate: startdate
    endDate: ''
    firstThreshold: firstThreshold
    secondThreshold: secondThreshold
    contactEmails: contactEmails
  }
}
