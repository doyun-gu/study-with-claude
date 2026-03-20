# Key Equations — Numerical Analysis

> Sample reference — regenerate from your own materials with "build big picture for numerical-analysis"

---

## 1. Error Analysis

### Absolute and Relative Error

$$E_{\text{abs}} = |x - \hat{x}|$$

$$E_{\text{rel}} = \frac{|x - \hat{x}|}{|x|}$$

- $x$ = true value, $\hat{x}$ = approximation
- Relative error is dimensionless — use it to compare errors across different scales

### Condition Number (Matrix)

$$\kappa(A) = \|A\| \cdot \|A^{-1}\|$$

- $\kappa \approx 1$: well-conditioned
- $\kappa \gg 1$: ill-conditioned — small input changes cause large output changes
- Relative error in solution bounded by: $\frac{\|\delta x\|}{\|x\|} \leq \kappa(A) \frac{\|\delta b\|}{\|b\|}$

### Taylor Series Remainder

$$f(x) = f(a) + f'(a)(x-a) + \frac{f''(a)}{2!}(x-a)^2 + \cdots + \frac{f^{(n)}(a)}{n!}(x-a)^n + R_n(x)$$

$$R_n(x) = \frac{f^{(n+1)}(\xi)}{(n+1)!}(x-a)^{n+1}, \quad \xi \in (a, x)$$

---

## 2. Root Finding

### Bisection Method

$$c = \frac{a + b}{2}$$

- If $f(a) \cdot f(c) < 0$: root in $[a, c]$
- If $f(c) \cdot f(b) < 0$: root in $[c, b]$
- Error after $n$ steps: $|e_n| \leq \frac{b - a}{2^n}$
- Convergence: linear, one bit of accuracy per step

### Newton-Raphson Method

$$x_{n+1} = x_n - \frac{f(x_n)}{f'(x_n)}$$

- Requires: $f'(x_n) \neq 0$, good initial guess
- Convergence: quadratic — $e_{n+1} \approx \frac{f''(\xi)}{2f'(\xi)} e_n^2$
- Fails when: $f'(x) = 0$ near root, poor initial guess, oscillation

### Secant Method

$$x_{n+1} = x_n - f(x_n) \frac{x_n - x_{n-1}}{f(x_n) - f(x_{n-1})}$$

- No derivative needed — approximates $f'$ from two previous points
- Convergence: superlinear, order $\phi = \frac{1 + \sqrt{5}}{2} \approx 1.618$

### Fixed-Point Iteration

$$x_{n+1} = g(x_n)$$

- Converges if $|g'(x)| < 1$ near the fixed point
- Error: $|e_{n+1}| \leq |g'(\xi)| \cdot |e_n|$

---

## 3. Interpolation

### Lagrange Interpolation

$$P(x) = \sum_{i=0}^{n} y_i \prod_{\substack{j=0 \\ j \neq i}}^{n} \frac{x - x_j}{x_i - x_j}$$

- Unique polynomial of degree $\leq n$ through $n+1$ points
- Interpolation error: $f(x) - P(x) = \frac{f^{(n+1)}(\xi)}{(n+1)!} \prod_{i=0}^{n}(x - x_i)$

### Newton Divided Differences

$$P(x) = f[x_0] + f[x_0, x_1](x - x_0) + f[x_0, x_1, x_2](x - x_0)(x - x_1) + \cdots$$

Where:
$$f[x_i, x_{i+1}, \ldots, x_{i+k}] = \frac{f[x_{i+1}, \ldots, x_{i+k}] - f[x_i, \ldots, x_{i+k-1}]}{x_{i+k} - x_i}$$

### Cubic Spline Conditions

For each interval $[x_i, x_{i+1}]$, $S_i(x)$ is a cubic polynomial satisfying:
1. $S_i(x_i) = y_i$ and $S_i(x_{i+1}) = y_{i+1}$ (interpolation)
2. $S_i'(x_{i+1}) = S_{i+1}'(x_{i+1})$ (smooth first derivative)
3. $S_i''(x_{i+1}) = S_{i+1}''(x_{i+1})$ (smooth second derivative)
4. Natural BC: $S_0''(x_0) = 0$, $S_{n-1}''(x_n) = 0$

---

## 4. Numerical Integration

### Trapezoidal Rule

$$\int_a^b f(x)\,dx \approx \frac{h}{2}\left[f(a) + 2\sum_{i=1}^{n-1} f(x_i) + f(b)\right]$$

- $h = (b - a)/n$
- Error: $-\frac{(b-a)h^2}{12} f''(\xi)$ — second-order, $O(h^2)$

### Simpson's 1/3 Rule

$$\int_a^b f(x)\,dx \approx \frac{h}{3}\left[f(a) + 4\sum_{\text{odd}} f(x_i) + 2\sum_{\text{even}} f(x_i) + f(b)\right]$$

- Requires even number of subintervals
- Error: $-\frac{(b-a)h^4}{180} f^{(4)}(\xi)$ — fourth-order, $O(h^4)$

### Gaussian Quadrature

$$\int_{-1}^{1} f(x)\,dx \approx \sum_{i=1}^{n} w_i f(x_i)$$

- Nodes $x_i$ are roots of Legendre polynomials
- Exact for polynomials of degree $\leq 2n - 1$
- For general $[a,b]$: transform via $x = \frac{b-a}{2}t + \frac{b+a}{2}$

| Points | Nodes | Weights |
|--------|-------|---------|
| 1 | $0$ | $2$ |
| 2 | $\pm 1/\sqrt{3}$ | $1, 1$ |
| 3 | $0, \pm\sqrt{3/5}$ | $8/9, 5/9, 5/9$ |

---

## 5. Linear Systems

### Gaussian Elimination with Partial Pivoting

Forward elimination to upper triangular form, then back substitution:

$$x_n = \frac{b_n'}{a_{nn}'}$$

$$x_i = \frac{1}{a_{ii}'}\left(b_i' - \sum_{j=i+1}^{n} a_{ij}' x_j\right), \quad i = n-1, \ldots, 1$$

- Partial pivoting: at each step, swap the row with the largest absolute value in the current column
- Cost: $\frac{2n^3}{3}$ flops

### LU Decomposition

$$A = LU$$

- $L$ = lower triangular (1s on diagonal), $U$ = upper triangular
- Solve $Ly = b$ (forward substitution), then $Ux = y$ (back substitution)
- Cost: $\frac{2n^3}{3}$ to factor, $2n^2$ per solve — efficient for multiple right-hand sides
- With pivoting: $PA = LU$

### Iterative Methods

**Jacobi:**
$$x_i^{(k+1)} = \frac{1}{a_{ii}}\left(b_i - \sum_{j \neq i} a_{ij} x_j^{(k)}\right)$$

**Gauss-Seidel:**
$$x_i^{(k+1)} = \frac{1}{a_{ii}}\left(b_i - \sum_{j < i} a_{ij} x_j^{(k+1)} - \sum_{j > i} a_{ij} x_j^{(k)}\right)$$

- Both converge if $A$ is strictly diagonally dominant: $|a_{ii}| > \sum_{j \neq i} |a_{ij}|$

---

## 6. Eigenvalues

### Power Method

$$v^{(k+1)} = \frac{Av^{(k)}}{\|Av^{(k)}\|}$$

- Converges to eigenvector of dominant eigenvalue $\lambda_1$
- Convergence rate: $|\lambda_2 / \lambda_1|^k$
- Eigenvalue estimate: Rayleigh quotient $\lambda \approx \frac{v^T A v}{v^T v}$

### Gershgorin Circle Theorem

Every eigenvalue lies in at least one disc:

$$D_i = \left\{ z \in \mathbb{C} : |z - a_{ii}| \leq \sum_{j \neq i} |a_{ij}| \right\}$$

---

## 7. Ordinary Differential Equations

### Forward Euler

$$y_{n+1} = y_n + h f(t_n, y_n)$$

- First order: local error $O(h^2)$, global error $O(h)$
- Stability: $|1 + h\lambda| \leq 1$

### Backward Euler (Implicit)

$$y_{n+1} = y_n + h f(t_{n+1}, y_{n+1})$$

- First order but unconditionally stable — use for stiff problems
- Requires solving nonlinear equation at each step

### Classical Runge-Kutta (RK4)

$$y_{n+1} = y_n + \frac{h}{6}(k_1 + 2k_2 + 2k_3 + k_4)$$

Where:
$$k_1 = f(t_n, y_n)$$
$$k_2 = f\left(t_n + \frac{h}{2}, y_n + \frac{h}{2}k_1\right)$$
$$k_3 = f\left(t_n + \frac{h}{2}, y_n + \frac{h}{2}k_2\right)$$
$$k_4 = f(t_n + h, y_n + h k_3)$$

- Fourth order: local error $O(h^5)$, global error $O(h^4)$
- The default choice for non-stiff ODEs

### Adams-Bashforth (2-step, explicit)

$$y_{n+1} = y_n + \frac{h}{2}\left[3f(t_n, y_n) - f(t_{n-1}, y_{n-1})\right]$$

---

## Quick Reference

| Method | What It Solves | Order | Key Formula |
|--------|---------------|-------|-------------|
| Bisection | $f(x) = 0$ | 1 | $c = (a+b)/2$ |
| Newton-Raphson | $f(x) = 0$ | 2 | $x_{n+1} = x_n - f/f'$ |
| Lagrange | Interpolation | $n$ | $\sum y_i \prod \frac{x-x_j}{x_i-x_j}$ |
| Trapezoidal | $\int f\,dx$ | 2 | $\frac{h}{2}[f_0 + 2\sum + f_n]$ |
| Simpson's | $\int f\,dx$ | 4 | $\frac{h}{3}[f_0 + 4\sum_{\text{odd}} + 2\sum_{\text{even}} + f_n]$ |
| Gauss Elim. | $Ax = b$ | exact | Forward elim + back sub |
| Euler | $y' = f(t,y)$ | 1 | $y_{n+1} = y_n + hf$ |
| RK4 | $y' = f(t,y)$ | 4 | $y_{n+1} = y_n + \frac{h}{6}(k_1+2k_2+2k_3+k_4)$ |
