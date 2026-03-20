# Exam Prep — Numerical Analysis

> Sample reference — regenerate from your own materials with "build big picture for numerical-analysis"

---

## Practice Questions

### Easy (Recall & Definition)

**E1.** What is the order of convergence of the bisection method? How many iterations are needed to achieve $10^{-6}$ accuracy starting from an interval of length 1?

**E2.** State the Newton-Raphson formula. What are two conditions under which it can fail?

**E3.** What is the difference between truncation error and round-off error? Give an example of each.

**E4.** For Simpson's rule, what order polynomial is integrated exactly? What is the error order?

**E5.** What does it mean for a matrix to be diagonally dominant? Why does this matter for iterative solvers?

**E6.** State the Gershgorin Circle Theorem. How is it useful in practice?

### Medium (Application)

**M1.** Use Newton-Raphson to find a root of $f(x) = x^3 - 2x - 5$, starting from $x_0 = 2$. Perform 3 iterations.

**M2.** Construct the Lagrange interpolating polynomial through $(1, 1)$, $(2, 4)$, $(3, 9)$. Verify it gives $P(2) = 4$.

**M3.** Compute $\int_0^1 e^x\,dx$ using:
- (a) Trapezoidal rule with $n = 4$
- (b) Simpson's rule with $n = 4$
- Compare both to the exact value $e - 1$.

**M4.** Solve the system using LU decomposition:
$$\begin{bmatrix} 2 & 1 & 1 \\ 4 & 3 & 3 \\ 8 & 7 & 9 \end{bmatrix} \begin{bmatrix} x_1 \\ x_2 \\ x_3 \end{bmatrix} = \begin{bmatrix} 1 \\ 1 \\ 1 \end{bmatrix}$$

**M5.** Apply two steps of Euler's method to $y' = -2y$, $y(0) = 1$, with $h = 0.25$. Compare to the exact solution $y = e^{-2t}$.

**M6.** Perform one iteration of Jacobi and Gauss-Seidel on:
$$\begin{bmatrix} 4 & -1 & 0 \\ -1 & 4 & -1 \\ 0 & -1 & 4 \end{bmatrix} \begin{bmatrix} x_1 \\ x_2 \\ x_3 \end{bmatrix} = \begin{bmatrix} 15 \\ 10 \\ 10 \end{bmatrix}$$
starting from $x^{(0)} = (0, 0, 0)^T$.

### Hard (Analysis & Synthesis)

**H1.** Derive the error term for the trapezoidal rule using Taylor expansion. Show that it is $O(h^2)$.

**H2.** The power method converges at rate $|\lambda_2/\lambda_1|$. For a matrix with eigenvalues $10, 9, 1$, how many iterations are needed for 6 decimal places of accuracy? How could you accelerate this?

**H3.** Compare forward Euler, backward Euler, and RK4 for the stiff ODE $y' = -1000y + 3000 - 2000e^{-t}$, $y(0) = 0$. What step size does forward Euler require? Why is backward Euler preferable?

**H4.** Explain Runge's phenomenon. Why does increasing the polynomial degree not always improve interpolation accuracy? Prove that Chebyshev nodes minimise the maximum interpolation error.

**H5.** Design a composite quadrature rule that is exact for polynomials of degree 5 using the fewest function evaluations. Justify your choice.

---

## Past Paper Patterns

_Drop your past papers into `materials/` and ask Claude to analyze them._

Typical Numerical Analysis exams test:
- **Always appears:** Newton-Raphson (apply + analyze convergence), Simpson's or trapezoidal (compute + error bound), Gaussian elimination or LU (hand-compute small system)
- **Usually appears:** Lagrange interpolation (construct polynomial), Euler or RK4 (apply to specific ODE), error analysis (condition number or floating-point)
- **Sometimes appears:** Power method, cubic splines, Gaussian quadrature, stiffness analysis, fixed-point iteration

## Exam Strategy

1. **Warm up with root finding** — Newton-Raphson questions are usually straightforward. Secure those marks first.
2. **Integration questions** — apply the formula carefully, watch for even/odd subinterval requirements (Simpson's needs even $n$).
3. **Linear systems** — show all pivoting steps. Marks are for method, not just the answer.
4. **ODE questions** — set up the tableau clearly. Label each $k_i$ for RK4.
5. **Error analysis** — state the error order, use Taylor expansion to justify. This is where strong students differentiate.
