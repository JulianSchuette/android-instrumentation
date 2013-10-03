import time

class Stopwatch():
    def __enter__(self):
        self.__start = time.time()
    def __exit__(self, type, value, traceback):
        self.__stop = time.time()
    def get_duration(self):
        duration = self.__stop-self.__start 
        self.__start=0
        self.__stop=0
        return duration
