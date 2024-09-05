# About decisions that were made
Honestly, I don’t usually participate in test assessments.
In fact, every job I’ve had in the past was offered without requiring one. But hey, there’s a first time for everything.
I took this opportunity to experiment with different tools, approaches, and design choices.
While not everything I tried ended up being something I enjoyed, that’s the nature of experimentation.
This project gave me a chance to explore new ideas, even if not all of them worked out as expected.

## Experiments

### Ruby 3.3.4
Extensively used modern features, such as pattern matching. Looks like its quite unorthodox.

### Minimum libraries
At least that was the idea. Ended up using quite a lot of them.

### Framework Sinatra
I just picked it because I have never used Sinatra before and it appeared to be second most popular after Rails.
Honestly, would not take it second time.

### Sequel db
Well, it was ok.

### A lot of functional programming
Lambdas, functions as params etc - that was another experiment. Some stuff I liked, some I did not.
The most pain was lack of support and type hinting from Rubymine. With all those lambdas and procs
and yields my Rubymine becomes dumb and you end up working in nano instead of IDE. Yard doest help much.

### Result err/ok
Same as previous point. Actually, I was going to try to use Elixir style pattern match [:ok, v] | [:err, reason] but ended up making Result helper class.

### Classes with private constructors + builder class methods.
This I actually enjoyed. Keeps invariants guarded, though I need some more time to play around this concept in Ruby.

### Railway programming
Well, kinda. It did not feel as good as it should. I guess its about dynamic typing. But also requires some more time to experiment, it might be ok.

## Design choices
### Vertical sliced architecture
Or at least an attempt.
Its actually very hard to do vertical slice without DDD and its even harder to do DDD without domain experts.

### Naming
This was the most challenging. You could find a lot of inconsistencies and I hope you understand.
Also, I did my best to avoid generic namings aka Model/Controller/Service as much as I could.
Though I did end up with `Infrastructure` as exception. That was necessary to distinguish between code with side effects and without.

### DI
That was done passing functions/objects as arguments to functions. More in Open-Ended Questions.

## Core application architecture
### Storage for original urls
I decided to use postgresql. Its tempting to take noSQL like Redis or mongo
- postgresql is enough at the beginning
- the nature of data is actually quite relational - short urls would have users, options, limits, configs, history, etc etc.

### Hash based VS Identity based encoding
Choice should be made how to encode url. It can be done hashing input data or using generated identity.
#### Hashing
Most url shorteners out use this approach.
- Collisions are the problem
- Can be mitigated by retries
- Or some tricks like generate bulk of hashes in one run
- But still requires to run to DB to check its available
- And still not a guarantee because of race


I decided to use Identity based encoding.

#### Identity based encoding
- For every /encode request application generates unique identity key (big integer, 58^5..58^6)
- Identity key is a Primary Key (meaning fast lookups)
- Identity key encoded into base58 string - becomes a token.
- Identity key is unique => token is unique.
- `short.est` (host) + token = short url (`short.est/token`)
- Token generation is not dependant on incoming original url => same url can be encoded multiple times
- Only default host (`short.est`) is currently supported, but can be enhanced

### Identity generation
There is a problem on how to generate this unique identity key.
- Generate random number - most services do it that way
- Same problem as with hashing - collisions
- UUID is quite unique, but its too big for short token
- Distributed unique key generation alike SNOWFLAKE - too complex to implement
- Generating from sequence - this is what I decided to use
#### Identity from sequence
I was going to use REDIS - it has atomic sequence feature. But decided not to introduce another dependency since 
postgresql is already used for storing original urls.
- pg sequence - generates integers that are unique on one server
- sequence is in the same postgresql database, but separate SCHEMA - for future extraction into separate server
##### Problem: sequence generation bottleneck
- sequence is in the same postgresql database, but separate SCHEMA - move it to separate server and scale vertically
- taking from sequence is atomic operation, so still can be bottleneck
- can be mitigated by having multiple sequence servers with custom step
- sequence1(1, 1+N, 1+2N, 1+3N, ...), sequence2(2, 2+N, 2+2N, 2+3N, ...), sequence3(3, 3+N, 3+2N, 3+3N, ...), ...sequenceN
- sequences with different steps can be distributed on different servers
- application servers can PRELOAD bulk of identities and store in memory and refill as on goes
- downside: if server is down identities are lost
#### Problem: since identities serial => tokens also serial and predictable
- can use custom alphabet for encoding
- can apply some secret when encode/decode

## Addressing points from README
### You need to think through potential attack vectors on the application, and document them in the README.
What first comes to mind
#### DDOS on /encode endpoint
- rate limiting
- access tokens
#### DDOS on /decode endpoint
- rate limiting
- access tokens
- cache
#### Brute-force guessing
- we talked about serial identifiers previously - custom alphabet + secret
- rate limiting
- custom hosts for encoding (paid feature)
#### Original urls that are actually short urls
- add additional step into validation flow on /encode via black lists of hosts
- background job that checks stored urls (if its redirect) and act accordingly
#### Original urls are bad urls
- same as previous
- feature to report our short url that is potentially bad
#### Original urls have sensitive information
- add additional step into validation flow on /encode

## You need to think through how your implementation may scale up, and document your approach in the README.
- add LRU cache. 

I actually did add in memory cache using gem 'moneta'. But I was not attentive enough to read documentation and missed the fact
that it is not shared between threads and processes, but using redis was overkill as I decided later so reverted.
- Maybe store TOKEN string instead of IDENTITY key in db - this will save on DECODE operations, which happen every time
/decode request is hit. But then it would add on index size and probably speed. Great candidate for benchmarking.
- Have multiple sequences for identities
- Have identity servers separate
- Sharding encoded urls table by identity ranges
- Preload identity keys in application server
- Async /encode
- separate /encode service, separate /decode service (eventual consistency) with fast key/value storage

# Evaluation Criteria

- Ruby best practices

Not always, but hopefully yes.
- API implemented featuring a /encode and /decode endpoint
+

- Completeness: did you complete the features? Are all the tests running?

While writing this README I just realised e2e test for /encode is commented. Damn, I did some quite big refactoring today 
and commented tests for it. And I forgot to update it.

- Correctness: does the functionality act in sensible, thought-out ways?

+
- Maintainability: is it written in a clean, maintainable way?

I hope so, though since this project has a lot of experimenting and is very unorthodox, it has a lot of questionable parts.
I would love to hear your opinion and dissects it.

- Security: have you through through potential issues and mitigated or documented them?

+
- Scalability: what scalability issues do you foresee in your implementation and how do you plan to work around those issues?

+

# Open-Ended Questions

## 1. Please, explain your own words how you understand the DRY principle — Don't Repeat Yourself.
For me its totally fine to have duplicated code. Its not about simmilar lines of code, but rather cohesion and behaviour.
DRY is done adding abstraction layer which incriases complexity by itself, so in order to do DRY both must be true:
1. DRY Abstraction abstracts reasonable complexity - meaning Complexity introduced by new abstraction < Complexity of what was hidden.
2. Abstracted behaviour is being cohesive - it should have a single responsibility or a single reason to change.


## 2. What is your least favorite recommendation in the community Ruby style guide? https://rubystyle.guide/ Please, explain if you have one.
Hm, idk. Maybe recommendation for small number of arguments in methods.
And duck typing over inheritance/mixins. Sure ruby is dynamic, but still its nice when IDE helps you with autocomplete.
I also hate rubocops default cop - size of method. Its too small.

## 3. Please, share a situation when you experienced working with a difficult coworker on a team. How was the coworker difficult and what did you do to resolve the situation to encourage the team's ongoing progress?
Usually "difficult" people are just people who are unmotivated for some reason.
## 4. Please, explain what is a dependency injection (DI). What place may it have in a typical Rails app? How would you structure a rails app to utilize dependency injection? If you think DI is not useful in Ruby/Rails applications, please, explain why.
I think you have seen I do value DI quite a lot. Technically in Rails DI is not useful indeed - in a sense that everything is available from anywhere. And Rspec can mock and spy on anything.
But it give a hit on maintenance, because without proper abstractions and without separation of concerns its much harder to refactor, build new features and change stuff
without breaking everything.
Not only that, but DI makes possible Inversion of Control, which is critical as it guards core functionality to evolve projected from chaotic changes in supporting features.
In rails for example
- functions like I did here or service objects (basically the same - its just 2 functions call instead of one)
- if functions, than we can either return lambda with closure dependencies
- or have builder function, in example function that takes dependency and return function
- of service object, than its constructor and storing dependency inside instance var
- setup in config initializers
- inject into controllers
- controllers can build more complicated objects that need deps
- and call them

Oh btw, if you wish please check post I made last year about (partially) [DI in ruby services](https://medium.com/@beard-programmer/service-objects-as-functions-a-functional-approach-to-build-business-flows-in-ruby-on-rails-bf34bf18331d).