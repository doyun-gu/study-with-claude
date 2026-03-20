# Flashcards — Numerical Analysis

> Sample reference — regenerate from your own materials with "build big picture for numerical-analysis"

---

## How to Use

Ask Claude: **"Quiz me on numerical analysis"** or **"Flashcards for root finding"**

---

## Cards

### Error Analysis

| Front | Back |
|-------|------|
| Define absolute error | $E_{\text{abs}} = \|x - \hat{x}\|$ — difference between true and approximate value |
| Define relative error | $E_{\text{rel}} = \|x - \hat{x}\| / \|x\|$ — error relative to true value's magnitude |
| What is machine epsilon? | Smallest $\epsilon$ such that $\text{fl}(1 + \epsilon) > 1$. For double precision: $\approx 2.2 \times 10^{-16}$ |
| What is catastrophic cancellation? | Loss of significant digits when subtracting nearly equal numbers. Example: $1.000001 - 1.000000$ loses 6 digits |
| What does condition number measure? | Sensitivity of a problem to perturbations in input. $\kappa(A) = \|A\| \cdot \|A^{-1}\|$ |
| $\kappa(A) = 10^8$. What does this mean? | Expect to lose about 8 digits of accuracy. If inputs have 16 digits, solution has ~8 reliable digits |

### Root Finding

| Front | Back |
|-------|------|
| Newton-Raphson formula | $x_{n+1} = x_n - f(x_n)/f'(x_n)$ |
| Convergence order: bisection | Linear — gains one binary digit per iteration |
| Convergence order: Newton | Quadratic — roughly doubles correct digits per iteration |
| Convergence order: secant | Superlinear — order $\phi \approx 1.618$ (golden ratio) |
| When does Newton fail? | $f'(x) = 0$ at root (multiple root), bad initial guess, or cycling |
| Fixed-point convergence condition | $\|g'(x)\| < 1$ in a neighbourhood of the fixed point |
| Bisection: iterations for $10^{-10}$ accuracy from $[0,1]$? | $n = \lceil \log_2(10^{10}) \rceil = 34$ iterations |

### Interpolation

| Front | Back |
|-------|------|
| Lagrange basis polynomial $L_i(x)$ | $L_i(x) = \prod_{j \neq i} \frac{x - x_j}{x_i - x_j}$, equals 1 at $x_i$ and 0 at all other nodes |
| Interpolation error bound | $\|f(x) - P_n(x)\| \leq \frac{\|f^{(n+1)}\|}{(n+1)!} \prod\|x - x_i\|$ |
| What is Runge's phenomenon? | High-degree polynomial interpolation on equally-spaced points oscillates wildly near endpoints |
| How to fix Runge's phenomenon? | Use Chebyshev nodes (clustered at endpoints) or piecewise splines |
| Cubic spline continuity | $C^2$ — function value, first and second derivatives all continuous at knots |

### Numerical Integration

| Front | Back |
|-------|------|
| Trapezoidal rule error order | $O(h^2)$ — error term involves $f''$ |
| Simpson's rule error order | $O(h^4)$ — error term involves $f^{(4)}$ |
| Simpson's special requirement | Must have even number of subintervals |
| Gaussian quadrature: why optimal? | $n$ points integrate polynomials of degree $2n-1$ exactly (vs. degree $n$ for Newton-Cotes) |
| Why is integration well-conditioned? | Smoothing operation — errors in $f$ get averaged out |
| Why is differentiation ill-conditioned? | Amplifies errors — subtracting nearby values magnifies noise |

### Linear Systems

| Front | Back |
|-------|------|
| Cost of Gaussian elimination | $\frac{2n^3}{3}$ floating-point operations |
| Why use LU instead of direct elimination? | Factor once ($O(n^3)$), solve for each new $b$ in $O(n^2)$ |
| Cholesky: when can you use it? | Matrix must be symmetric positive definite. $A = LL^T$, half the cost of LU |
| Jacobi convergence guarantee | Converges if $A$ is strictly diagonally dominant |
| Gauss-Seidel vs Jacobi | G-S uses updated values immediately — generally converges faster |
| What is partial pivoting? | At each step, swap current row with the row having largest absolute value in the pivot column |

### Eigenvalues

| Front | Back |
|-------|------|
| Power method finds... | The dominant (largest magnitude) eigenvalue and its eigenvector |
| Power method convergence rate | $\|\lambda_2 / \lambda_1\|^k$ — slow if $\lambda_2 \approx \lambda_1$ |
| Inverse power method finds... | Eigenvalue closest to a given shift $\sigma$ |
| Gershgorin: eigenvalue location | Each $\lambda$ lies in some disc $\|z - a_{ii}\| \leq \sum_{j \neq i} \|a_{ij}\|$ |

### ODEs

| Front | Back |
|-------|------|
| Forward Euler formula | $y_{n+1} = y_n + h f(t_n, y_n)$ — first order |
| RK4 order of accuracy | Fourth order: local error $O(h^5)$, global error $O(h^4)$ |
| What makes a problem "stiff"? | Components with vastly different timescales — explicit methods need tiny $h$ |
| How to handle stiff ODEs | Use implicit methods: backward Euler, BDF, implicit Runge-Kutta |
| What is A-stability? | Stability region contains entire left half-plane — method is stable for all stable problems |
| Forward Euler stability condition for $y' = \lambda y$ | $\|1 + h\lambda\| \leq 1$ — restricts step size |

---

## Difficult Cards

_Cards you get wrong during study sessions will be collected here for focused review._
