# ---------------------------------------------------------
# 1. Funciones ponderadas (las traemos de la clase)
# ---------------------------------------------------------
# Ya tenemos weighted.mean() en base R. Definimos el resto.

mediana_ponderada <- function(x, w) {
  ok <- !is.na(x) & !is.na(w)
  x <- x[ok]; w <- w[ok]
  o <- order(x)
  x <- x[o]; w <- w[o]
  cw <- cumsum(w) / sum(w)
  x[which(cw >= 0.5)[1]]
}

percentil_ponderado <- function(x, w, p) {
  ok <- !is.na(x) & !is.na(w)
  x <- x[ok]; w <- w[ok]
  o <- order(x)
  x <- x[o]; w <- w[o]
  cw <- cumsum(w) / sum(w)
  x[which(cw >= p)[1]]
}

desvio_ponderado <- function(x, w) {
  ok <- !is.na(x) & !is.na(w)
  x <- x[ok]; w <- w[ok]
  m <- weighted.mean(x, w)
  sqrt(sum(w * (x - m)^2) / sum(w))
}

asimetria_ponderada <- function(x, w) {
  ok <- !is.na(x) & !is.na(w)
  x <- x[ok]; w <- w[ok]
  m <- weighted.mean(x, w)
  s <- desvio_ponderado(x, w)
  sum(w * ((x - m) / s)^3) / sum(w)
}

curtosis_ponderada <- function(x, w) {
  ok <- !is.na(x) & !is.na(w)
  x <- x[ok]; w <- w[ok]
  m <- weighted.mean(x, w)
  s <- desvio_ponderado(x, w)
  sum(w * ((x - m) / s)^4) / sum(w) - 3
}
