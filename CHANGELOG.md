0.3.0 (March 30, 2014)

* Move development dependencies to Gemfile
* Increase test coverage to 95%
* Fix bug with event methods dynamic redefinition
* Change attr_threadsafe to accept default values
* Fix observer respond_to
* Add ability to specify callbacks on machine instance
* Add once_on type of callback
* Add off method for removing callbacks
* Add async method to state_machine for asynchronous events firing
* Fix Callable to correctly forward arguments
* Add state helpers fsm.green? to allow easily check current state

0.2.0 (March 01, 2014)

* Ensure correct transition object state
* Add methods synchronization for thread safety
* Fix bug - callback event object returns correct from state
* Add ability to define custom initial event
* Add hooks class for callbacks registration
* Extend threadable accessors
* Add generic state and event listeners
* Add target to allow integration with external objects,
  and allow easy method lookup through callback context
* Add ability to specify custom handlers for error conditions
