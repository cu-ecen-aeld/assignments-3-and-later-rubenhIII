#include "threading.h"
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

// Optional: use these functions to add debug or error prints to your application
//#define DEBUG_LOG(msg,...)
#define DEBUG_LOG(msg,...) printf("threading: " msg "\n" , ##__VA_ARGS__)
#define ERROR_LOG(msg,...) printf("threading ERROR: " msg "\n" , ##__VA_ARGS__)

void* threadfunc(void* thread_param)
{

    // TODO: wait, obtain mutex, wait, release mutex as described by thread_data structure
    // hint: use a cast like the one below to obtain thread arguments from your parameter
    //struct thread_data* thread_func_args = (struct thread_data *) thread_param;
	
	struct thread_data *thread_func_args = (struct thread_data*)thread_param;

//	printf("time to obtain: %d\n", thread_func_args->wait_to_obtain_ms);
//	printf("time to release: %d\n", thread_func_args->wait_to_release_ms);

//	
//	fflush(stdout);


	usleep((thread_func_args->wait_to_obtain_ms) * 1000);
	pthread_mutex_lock(thread_func_args->lock);
//	printf("Lock result %d from %d\n", un, (int)pthread_self());
	usleep((thread_func_args->wait_to_release_ms) * 1000);
	pthread_mutex_unlock(thread_func_args->lock);
//	printf("Unlock result %d\n", un);
	
	thread_func_args->thread_complete_success = true;
	//if (un!=0 || un2!=0)
	//	thread_func_args->thread_complete_success = false;

	printf("pointer %p\n", &thread_func_args->lock);

	return thread_param;
}


bool start_thread_obtaining_mutex(pthread_t *thread, pthread_mutex_t *mutex,int wait_to_obtain_ms, int wait_to_release_ms)
{
    /**
     * TODO: allocate memory for thread_data, setup mutex and wait arguments, pass thread_data to created thread
     * using threadfunc() as entry point.
     *
     * return true if successful.
     *
     * See implementation details in threading.h file comment block
     */
	struct thread_data *data = (struct thread_data*)malloc(sizeof(struct thread_data));
	data->wait_to_obtain_ms = wait_to_obtain_ms;
	data->wait_to_release_ms = wait_to_release_ms;
/*	
	if (pthread_mutex_init(mutex, NULL) != 0) {
		ERROR_LOG("MUTEX init has failed \n");
		return false;
	}
*/
	data->lock = mutex;

	if (pthread_create(thread, NULL, &threadfunc, data) != 0) {
		ERROR_LOG("Thread creation has failed \n");
		return false;
	}

	return true;
}

