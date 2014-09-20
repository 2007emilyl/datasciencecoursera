## Matrix inversion is usually a costly computation and there may be
## benefit to caching the inverse of a matrix rather than compute it repeatedly. 
## To write a pair of functions that cache the inverse of a matrix.


## This function creates a special "matrix" object that can cache its inverse.
## makeCacheMatrix function contains a function to:

## set the value of the matrix
## get the value of the matrix
## set the value of the inverse
## get the value of the inverse

makeCacheMatrix <- function(x = matrix()) {
        i <- NULL
        set <- function(y) {
                x <<- y
                i <<- NULL
        }
        get <- function() x
        set_inverse <- function(inverse) i <<- inverse
        get_inverse <- function() i
        list(set = set, get = get,
             set_inverse = set_inverse,
             get_inverse = get_inverse)

}


## This function computes the inverse of the special "matrix" returned by 
## makeCacheMatrix above. If the inverse has already been calculated 
## (and the matrix has not changed), then the cachesolve should retrieve 
## the inverse from the cache.

cacheSolve <- function(x, ...) {
        ## Return a matrix that is the inverse of 'x'
        i <- x$get_inverse()
        if(!is.null(i)) {
                message("getting cached data")
                return(i)
        }
        data <- x$get()
        ## m <- mean(data, ...)
        ## Computing the inverse of a square matrix X can be done with solve(X) 
        i <- solve(data)
        x$set_inverse(i)
        i
}
