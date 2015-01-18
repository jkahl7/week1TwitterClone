// Playing around with a Queue Data sructure. 

import UIKit

class Customer {
  var name:String
  var hasBurrito:Bool
  
  init(name:String, hasBurrito:Bool) {
    self.name = name
    self.hasBurrito = hasBurrito
  }
}


class Chipolte {
  
  var myQueue = [Customer]()
  
  //hungry people getting in line for some burrito lovin.
  func enQueue(customer:Customer) {
    customer.hasBurrito = false
    self.myQueue.append(customer)
  }
  
  //yum it's burrito time!
  func deQueue() {
    if (!self.myQueue.isEmpty) {
      self.myQueue[0].hasBurrito = true
      self.myQueue.removeAtIndex(0)
    } else {
      println("There are no customers left!")
    }
  }
  
  //whos next? -
  func peek() -> Customer? {
    if (!self.myQueue.isEmpty) {
      return self.myQueue[0]
    } else {
      println("There are no customers left!")
      return nil
    }
  }
  
  //TODO: implement method for detecting if a customer has a food baby. maybe.
  
}


let Chuck = Customer(name: "Chuck", hasBurrito: false)
var Sarah = Customer(name: "Sarah", hasBurrito: false)
var Bevis = Customer(name: "Bevis", hasBurrito: false)
var Linus = Customer(name: "Linus", hasBurrito: false)
var Marge = Customer(name: "Marge", hasBurrito: false)

let chipolte = Chipolte()

chipolte.enQueue(Chuck)
chipolte.enQueue(Sarah)
chipolte.enQueue(Bevis)
chipolte.enQueue(Linus)
chipolte.enQueue(Marge)


chipolte.myQueue

//lucky chuck gets his burrito
Chuck
chipolte.deQueue()
Chuck

chipolte.myQueue.count

chipolte.deQueue()
chipolte.deQueue()
chipolte.deQueue()

chipolte.myQueue.count





















