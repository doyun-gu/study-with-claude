# Big Picture — Numerical Analysis

> Sample reference — regenerate from your own materials with "build big picture for numerical-analysis"

---

## Core Topics

### 1. Error Analysis and Floating-Point Arithmetic

The foundation of all numerical methods. Every computation introduces error — understanding where it comes from and how it propagates is essential.

- **Absolute error:** $|x - \hat{x}|$ where $\hat{x}$ is the approximation
- **Relative error:** $|x - \hat{x}| / |x|$
- **Machine epsilon ($\epsilon_{\text{mach}}$):** Smallest number such that $\text{fl}(1 + \epsilon) > 1$
- **Catastrophic cancellation:** Loss of significant digits when subtracting nearly equal numbers
- **Condition number:** Measures sensitivity of a problem to input perturbations. $\kappa(A) = \|A\| \cdot \|A^{-1}\|$

**Key insight:** A well-conditioned problem solved by a stable algorithm gives accurate results. An ill-conditioned problem or unstable algorithm can give garbage regardless of precision.

### 2. Root Finding

Given $f(x) = 0$, find $x$.

| Method | Convergence | Requires | Guaranteed? |
|--------|------------|----------|-------------|
| Bisection | Linear, $O(1/2^n)$ | Bracket $[a,b]$ with sign change | Yes (if continuous) |
| Newton-Raphson | Quadratic, $O(e_n^2)$ | $f'(x)$, good initial guess | No |
| Secant | Superlinear, $O(e_n^{1.618})$ | Two initial points | No |
| Fixed-point | Linear (if converges) | $g(x) = x$ form, $|g'(x)| < 1$ | If contraction |

**When to use what:**
- Know nothing about $f$ → Bisection first, then switch to Newton
- $f'(x)$ expensive → Secant method
- System of equations → Multidimensional Newton

### 3. Interpolation and Approximation

Given data points $(x_i, y_i)$, construct a function passing through them.

- **Lagrange interpolation:** Unique polynomial of degree $\leq n$ through $n+1$ points. Simple but $O(n^2)$ to evaluate.
- **Newton divided differences:** Same polynomial, but incremental — adding a point doesn't redo everything.
- **Cubic splines:** Piecewise cubic, $C^2$ continuity. Avoids Runge's phenomenon (oscillation at edges with high-degree polynomials).
- **Chebyshev nodes:** Optimal interpolation points that minimise maximum error. Clustered at endpoints.

**Runge's phenomenon:** Equally-spaced high-degree polynomial interpolation oscillates wildly near boundaries. Fix: use splines or Chebyshev nodes.

### 4. Numerical Differentiation and Integration

**Differentiation** (inherently ill-conditioned):
- Forward difference: $f'(x) \approx [f(x+h) - f(x)] / h$, error $O(h)$
- Central difference: $f'(x) \approx [f(x+h) - f(x-h)] / 2h$, error $O(h^2)$
- Too-small $h$ → round-off dominates. Too-large $h$ → truncation dominates.

**Integration** (inherently well-conditioned):
| Rule | Formula | Error Order |
|------|---------|-------------|
| Trapezoidal | $\frac{h}{2}[f(a) + 2\sum f(x_i) + f(b)]$ | $O(h^2)$ |
| Simpson's 1/3 | $\frac{h}{3}[f(a) + 4\sum f_{\text{odd}} + 2\sum f_{\text{even}} + f(b)]$ | $O(h^4)$ |
| Gaussian quadrature | $\sum w_i f(x_i)$ with optimal nodes | $O(h^{2n})$ for $n$ points |

**Key insight:** Integration smooths errors (well-conditioned). Differentiation amplifies them (ill-conditioned). Prefer integration-based approaches when possible.

### 5. Linear Systems

Solving $Ax = b$.

**Direct methods** (exact in exact arithmetic):
- **Gaussian elimination** with partial pivoting: $O(n^3)$, the workhorse
- **LU decomposition:** Factor $A = LU$ once, then solve $Ly = b$, $Ux = y$. Efficient for multiple right-hand sides.
- **Cholesky:** For symmetric positive definite matrices: $A = LL^T$. Half the work of LU.

**Iterative methods** (for large sparse systems):
- **Jacobi:** Update each $x_i$ using previous iteration values. Simple but slow.
- **Gauss-Seidel:** Use updated values immediately. Faster convergence.
- **SOR (Successive Over-Relaxation):** Gauss-Seidel with relaxation parameter $\omega$. Optimal $\omega$ can dramatically speed convergence.
- **Conjugate Gradient:** For SPD matrices. Converges in at most $n$ steps (theoretically).

**Convergence condition:** Iterative methods converge if the spectral radius $\rho(T) < 1$ where $T$ is the iteration matrix. Diagonal dominance guarantees convergence for Jacobi and Gauss-Seidel.

### 6. Eigenvalue Problems

Finding $Av = \lambda v$.

- **Power method:** Finds the dominant eigenvalue. Simple but only gets one eigenvalue.
- **Inverse power method:** Finds eigenvalue closest to a shift $\sigma$. Uses $(A - \sigma I)^{-1}$.
- **QR algorithm:** The standard method for all eigenvalues. Reduces to upper triangular form iteratively.
- **Gershgorin circles:** Quick bounds on eigenvalue locations: each eigenvalue lies in at least one disc $|z - a_{ii}| \leq \sum_{j \neq i} |a_{ij}|$.

### 7. Ordinary Differential Equations (ODEs)

Solving $y' = f(t, y)$, $y(t_0) = y_0$.

| Method | Order | Steps | Stability |
|--------|-------|-------|-----------|
| Euler (forward) | 1 | Single | Conditionally stable |
| Euler (backward/implicit) | 1 | Single | Unconditionally stable |
| Midpoint (RK2) | 2 | Single | Conditionally stable |
| Classical RK4 | 4 | Single | Conditionally stable |
| Adams-Bashforth | Variable | Multi | Explicit |
| Adams-Moulton | Variable | Multi | Implicit |
| BDF | Variable | Multi | Stiff-stable |

**Stiff problems:** Systems where some components decay much faster than others. Explicit methods require absurdly small step sizes. Use implicit methods (backward Euler, BDF, implicit RK).

**Stability region:** Set of $h\lambda$ values where the method doesn't blow up. A-stable methods include the entire left half-plane (all implicit methods above).

---

## Topic Map

```
Error Analysis ──────────────────────────────────┐
  │                                               │
  ├── Root Finding                                │
  │     └── Newton needs f'(x) ← Differentiation │
  │                                               │
  ├── Interpolation                               │
  │     ├── Basis for Integration rules           │
  │     └── Basis for ODE methods                 │
  │                                               │
  ├── Integration                                 │
  │     └── Used in implicit ODE solvers          │
  │                                               │
  ├── Linear Systems                              │
  │     ├── Newton for systems needs this         │
  │     ├── Implicit ODE solvers need this        │
  │     └── Eigenvalue methods build on this      │
  │                                               │
  └── ODEs                                        │
        └── Error analysis ties everything ───────┘
```

---

## Key Themes Across All Topics

1. **Accuracy vs. cost tradeoff:** Higher-order methods are more accurate per step but cost more per step. Sometimes many cheap steps beat few expensive ones.
2. **Stability matters as much as accuracy:** A method can be perfectly accurate in theory but useless in practice if it's unstable for your problem.
3. **Condition number is the ceiling:** No algorithm can solve an ill-conditioned problem accurately. Check condition before blaming the method.
4. **Exploit structure:** Sparse, symmetric, positive definite, banded — special structure enables specialised (faster, more stable) algorithms.
