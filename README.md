# Objective

Your assignment is to implement a URL shortening service using Ruby. You can use any framework you want (or no framework at all, it is up to you).

There are also 4 questions at the end of the README, please, provide your answers to them in a separate file.

# Brief

ShortLink is a URL shortening service where you enter a URL such as https://codesubmit.io/library/react and it returns a short URL such as https://short.est/GeAi9K .

# Tasks

- Implement assignment using Ruby.
- Two endpoints are required
  - `/encode` - Encodes a URL to a shortened URL
  - `/decode` - Decodes a shortened URL to its original URL.
- Both endpoints should accept and return JSON. Successful payloads are described below, you can pick any format you want for errors.
- There is no restriction on how your encode/decode algorithm should work. You just need to make sure that a URL can be encoded to a short URL and the short URL can be decoded to the original URL.
- Your application needs to be able to decode previously encoded URLs after a restart.
- Do not build any authentication mechanisms.
- Provide detailed instructions on how to run your assignment in a separate markdown file.
- Provide tests for both endpoints (and any other tests you may want to write).
- You need to think through potential attack vectors on the application, and document them in the README.
- You need to think through how your implementation may scale up, and document your approach in the README. **You do not need to build a scalable service for this challenge but you need to document how you would approach building a scalable version of it..**

## Encode Endpoint API

**URL**: `POST /encode`

**Request Body**
```json5
{
  "url": "https://codesubmit.io/library/react"
}
```

### Success Response

**Code** : `200 OK`

**Content example**

```json5
{
  "url": "https://codesubmit.io/library/react",
  "short_url": "https://short.est/GeAi9K"
}
```

## Decode Endpoint API

**URL**: `POST /decode`

**Request Body**
```json5
{
  "short_url": "https://short.est/GeAi9K"
}
```

### Success Response

**Code** : `200 OK`

**Content example**

```json5
{
  "url": "https://codesubmit.io/library/react",
  "short_url": "https://short.est/GeAi9K"
}
```


# Evaluation Criteria

- Ruby best practices
- API implemented featuring a /encode and /decode endpoint
- Completeness: did you complete the features? Are all the tests running?
- Correctness: does the functionality act in sensible, thought-out ways?
- Maintainability: is it written in a clean, maintainable way?
- Security: have you through through potential issues and mitigated or documented them?
- Scalability: what scalability issues do you foresee in your implementation and how do you plan to work around those issues?

# Open-Ended Questions

1. Please, explain your own words how you understand the DRY principle — Don't Repeat Yourself.
2. What is your least favorite recommendation in the community Ruby style guide? https://rubystyle.guide/ Please, explain if you have one.
3. Please, share a situation when you experienced working with a difficult coworker on a team. How was the coworker difficult and what did you do to resolve the situation to encourage the team's ongoing progress?
4. Please, explain what is a dependency injection (DI). What place may it have in a typical Rails app? How would you structure a rails app to utilize dependency injection? If you think DI is not useful in Ruby/Rails applications, please, explain why.

# CodeSubmit

Please organize, design, test and document your code as if it were going into production - then push your changes to the master branch. After you have pushed your code, you may submit the assignment on the assignment page.

All the best and happy coding,

The nami.ai Team
