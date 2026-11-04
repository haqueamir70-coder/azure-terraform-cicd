# Terraform CI/CD — Advanced Interview Question Bank

> 40 additional questions and answers. Use with [ZERO-TO-HERO.md](./ZERO-TO-HERO.md). Validate claims against source, CI and deployment evidence.

## Project context
- **Architecture:** PR → fmt/init/validate/lint/scan → protected OIDC plan → review → controlled apply
- **Tools:** GitHub Actions, Terraform, AzureRM, Entra OIDC, Azure RBAC, GitHub Environments, Checkov, TFLint, remote state
- **Failure modes:** OIDC claim mismatch, RBAC denial, stale plan, state lock, leaked secret
- **Mitigation:** Separate authentication from authorization, scope OIDC claims, use protected environments, apply reviewed plans and rotate exposed credentials.

## Answer method
Context → decision → implementation → trade-off → failure handling → evidence.

## 40 questions with answers

### 1. What business problem does this project solve?

Explain the user/operator pain, business impact and measurable outcome. The architecture is a means to that outcome.

### 2. Who are the actors and trust boundaries?

Identify users, developers, operators, workload identities and external services. Mark where identity and network trust change.

### 3. Explain the end-to-end flow.

Walk through each component and hand-off, naming protocol, identity, persistence boundary and response path.

### 4. Why split the architecture into these components?

Each component has bounded responsibility, independent scaling/failure domain and explicit interface.

### 5. Which non-functional requirements matter?

Availability, latency, throughput, security, recoverability, auditability, operability and cost. Rank and measure them.

### 6. Why use the primary IaC/orchestration tool?

It makes desired state repeatable, reviewable and automatable. Explain alternatives and operational trade-offs.

### 7. What does CI validate—and not validate?

Static checks do not prove deployment, live permissions, network reachability, runtime behavior or disaster recovery.

### 8. How are environment differences handled?

Separate reusable logic from environment inputs, validate types, keep secrets out of source and promote explicitly.

### 9. How do you make deployment reproducible?

Pin tool/provider/action versions, lock dependencies, use immutable artifacts and version module interfaces.

### 10. How are secrets managed?

Prefer managed/workload identity or OIDC, least privilege and a secret manager. Rotate and audit; never print credentials.

### 11. What failure would you test first?

Choose a high-impact dependency failure and define detection, user impact, mitigation, recovery and evidence.

### 12. How do you troubleshoot an outage?

Scope impact, inspect recent changes, logs/events/metrics, identity, DNS/network, dependencies and saturation.

### 13. Authentication versus authorization?

Authentication proves identity; authorization decides allowed actions at a resource/data scope.

### 14. How do you enforce least privilege?

Use dedicated identities, narrow scopes and minimum actions; review privileged operations.

### 15. How do you prevent drift?

Use reviewed desired state, scheduled detection and controlled break-glass changes followed by reconciliation.

### 16. What should logs contain or exclude?

Log timestamps, correlation IDs, outcomes and timings. Exclude passwords, tokens, keys and sensitive payloads.

### 17. How do you retry safely?

Use bounded exponential backoff with jitter and idempotency/deduplication for repeated delivery.

### 18. How do you design recovery?

Set RPO/RTO, protect backups, test restore and validate application consistency.

### 19. How would you scale it?

Measure bottlenecks and latency/throughput/saturation, scale constrained tiers and validate cost.

### 20. Which metrics should operators monitor?

Availability, error rate, latency percentiles, throughput, saturation, queue lag and dependency health.

### 21. How do you reduce alert noise?

Alert on sustained actionable symptoms, suppress duplicates and include ownership/runbooks.

### 22. What security gates belong in CI?

Combine secret, dependency, source, image and IaC scans with severity and time-bound exceptions.

### 23. What are the cost drivers?

Compute, storage, egress, managed service tiers, telemetry and idle capacity. Track cost per useful unit.

### 24. How do you roll back safely?

Keep known-good immutable artifacts, define triggers and data compatibility, restore and monitor.

### 25. What evidence proves implementation?

Source, tests, workflow runs, deployment IDs, live checks, security evidence, telemetry and runbooks.

### 26. What is implemented versus planned?

Inspect source and workflows; label implemented, CI-validated, cloud-deployed or planned.

### 27. How do you test end to end?

Test happy path, invalid input, denied access, dependency outage, retry, scale, rollback and recovery.

### 28. What are the key trade-offs?

Discuss simplicity/flexibility, cost/availability, centralization/autonomy and security/usability.

### 29. What would you improve next?

Prioritize missing tests, weak identity, unverified recovery, missing telemetry or unclear ownership.

### 30. Give a 2-minute explanation.

State business problem, architecture, decisions, security/reliability controls, failure scenario and evidence.

### 31. Explain Terraform CI/CD architecture.

PR → fmt/init/validate/lint/scan → protected OIDC plan → review → controlled apply. Explain trust boundaries, failure domains and data/control hand-offs.

### 32. Which tools are used and why?

Tool inventory: GitHub Actions, Terraform, AzureRM, Entra OIDC, Azure RBAC, GitHub Environments, Checkov, TFLint, remote state. Explain responsibility, configuration, integration, limitations and alternatives; separate required from optional tools.

### 33. What are the key failure modes?

Main risks: OIDC claim mismatch, RBAC denial, stale plan, state lock, leaked secret. Prioritize by impact and likelihood; define detection, containment and recovery.

### 34. How would you troubleshoot the likely incident?

Separate authentication from authorization, scope OIDC claims, use protected environments, apply reviewed plans and rotate exposed credentials. Inspect scope/recent changes, logs/metrics/events, isolate layers and verify with a regression test.

### 35. How do you prove security controls work?

Create positive and negative tests for identity, authorization and network paths. Confirm permitted actions succeed and unauthorized actions fail.

### 36. How do you prove it is implemented?

Show source, tests, CI runs, deployment/resource IDs and live checks. Label implemented, CI-validated, cloud-deployed or planned.

### 37. What would you demo to a CTO?

Reproduce validation/build, trace architecture, show source/config, one successful and one failing test, telemetry and rollback.

### 38. What are the operational limits?

Identify quotas, throughput/concurrency limits, state/partition constraints, dependencies and recovery objectives; test representative load.

### 39. How improve maintainability?

Use cohesive modules, explicit interfaces, typed configuration, pinned dependencies, automated tests and actionable runbooks.

### 40. How measure success?

Choose indicators tied to business outcome: reliability, latency, freshness, deployment lead time, policy compliance or unit cost.

## Source-code file-by-file deep dive

For each real file, record its exact path and explain:
1. **Terraform:** required_version, providers, backend, variables/validation, locals, data, resources, dependencies, lifecycle, outputs and state addresses.
2. **GitHub Actions:** triggers, permissions, runner, actions, environment, secrets/identity, working directory, each step, artifacts, conditions and failures.
3. **Docker:** base image, context, layers, ARG/ENV, COPY, ENTRYPOINT/CMD, user, ports, health check and filesystem.
4. **Kubernetes:** apiVersion/kind, metadata, selectors, replicas, strategy, image digest, probes, resources, securityContext, service account, volumes, Service and Ingress.
5. **Application code:** entry point, config, validation, business logic, errors, retries/timeouts, authN/authZ, logs, metrics and tests.
6. **Policy/observability:** every rule, allowed/denied fixture, exit code, metric/label, PromQL, alert window and runbook.

## Hands-on mastery labs
- Trace a real change from commit to final resource/workload.
- Break a safe test dependency and diagnose it from telemetry.
- Demonstrate allowed and denied access paths.
- Change an input and explain the plan/build diff.
- Reproduce a CI failure and fix it.
- Roll back to a known-good version.
- Build evidence matrix: implemented | CI-validated | cloud-deployed | planned.

## Honesty rule
Optional architecture tools are not automatically implemented dependencies. Legacy and conceptual projects remain design exercises until code and tests prove functionality. A diagram or static validation is not deployment evidence.
