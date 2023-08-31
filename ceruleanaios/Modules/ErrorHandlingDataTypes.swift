//
//  ErrorHandlingDataTypes.swift
//  ceruleanaios
//
//  Created by Amaan Syed on 09/04/2021.
//

import Foundation

enum TaskState: Int, Codable {
    case Idle = 0
    case LoggingIn = 1
    case LoggedIn = 2
    case AwaitingProduct = 4
    case ProductOOS = 5
    case AwaitingCaptcha = 6
    case ItemCarted = 7
    case GettingShipping = 8
    case SubmittingShipping = 9
    case SubmittingDelivery = 10
    case AdvancingAPICheckout = 11
    case SubmittingPayment = 12
    case CardDeclined = 13
    case OrderComplete = 14
}

enum TaskInternalState: Int, Codable {
    case Idle = 0
    case AttemptingLogin = 1
    case LoggedIn = 2
    case AttempingGetCountryISO = 3
    case ObtainedUserCountry = 4
    case AttemptingGetCSRF = 5
    case ObtainedCSRF = 6
    case AttemptingClearCart = 7
    case ClearedCart = 8
    case AttemptingObtainingCart = 9
    case ObtainedCartObject = 10
    case AttemptingObtainingCheckout = 11
    case ObtainedCheckoutObject = 12
    case AwaitingProduct = 13
    case ProductFound = 14
    case AttemptingToCart = 15
    case ItemCarted = 16
    case AttemptingCheckoutAdvance = 17
    case CheckoutAdvanced = 18
    case AttemptingObtainingPayPalLink = 19
    case ObtainedPayPalLink = 20
    case AttemptingCardPayment = 21
    case CardPaymentSuccess = 22
    case StockChecked = 23
    case AttemptingAddressAndMethod = 24
    case PostedAddressAndMethod = 25
}


struct TaskErrorState {
    let error: TaskError
    let state: TaskInternalState
    let taskStatus:String
}

enum CheckoutState: String, Codable {
    case Cart = "cart"
    case Address = "address"
    case Delivery = "delivery"
    case Payment = "payment"
    case Complete = "complete"
}

enum TaskError: Error {
    case RequestError
    case NilResponse
    case NilResponseData
    case InvalidCredentials
    case InvalidStatusCode
    case TaskBanned
    case EncodingError
    case DecodingError
    case NoBillingAddress
    case ProductOOS
    case ProductDoesNotExist
    case NoAddress
    case NoCountry
    case NoCSRF
    case SwiftSoupError
    case CartNotEmpty
    case NoAPIKey
    case InvalidAPIKey
    case InvalidOrderState
    case InvalidAPIResponse
    case NoOrderObject
    case UnhandledError
    case ServerError
}

