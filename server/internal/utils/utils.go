package utils

func Map[T any, V any](arr []T, cb func(T, int) V) []V {
	mapped := make([]V, len(arr))
	for i, v := range arr {
		mapped[i] = cb(v, i)
	}
	return mapped
}

func Reduce[T any, V any](arr []T, cb func(V, T, int) V, initial V) V {
	var result V = initial
	for i, val := range arr {
		result = cb(result, val, i)
	}
	return result
}
