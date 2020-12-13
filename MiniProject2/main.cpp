#include <iostream>
#include <mutex>
#include <thread>
#include <chrono>
#include <vector>
#include <functional>

std::mutex mtx;

class DoubleRoom {
private:
    char firstPersonGender;
    char secondPersonGender;

    bool IsEmpty() {
        return (firstPersonGender == '-') && (secondPersonGender == '-');
    }

public:
    DoubleRoom() {
        this->firstPersonGender = '-';
        this->secondPersonGender = '-';
    }

    bool AddClient(char personGender) {
        if (IsEmpty()) {
            this->firstPersonGender = personGender;
            return true;
        } else if (this->secondPersonGender == '-') {
            if (this->firstPersonGender == personGender) {
                this->secondPersonGender = personGender;
                return true;
            } else {
                return false;
            }
        }
        return false;
    }
};

class Hotel{
private:
    static const int NUMBER_OF_SINGLE_ROOMS = 10;
    static const int NUMBER_OF_DOUBLE_ROOMS = 15;

    char singleRooms[NUMBER_OF_SINGLE_ROOMS];
    DoubleRoom doubleRooms[NUMBER_OF_DOUBLE_ROOMS];
    int clientNumber;

public:
    Hotel() {
        for (int i = 0; i < NUMBER_OF_SINGLE_ROOMS; ++i) {
            singleRooms[i] = '-';
        }
        clientNumber = 0;
    }

    ~Hotel() {
        free(doubleRooms);
        free(singleRooms);
    }

    std::string CheckInAClient(char gender) {
        mtx.lock();
        clientNumber++;
        int i = 0;
        while (!doubleRooms[i].AddClient(gender) && (i < NUMBER_OF_DOUBLE_ROOMS)) {
            i++;
        }
        if (i == NUMBER_OF_DOUBLE_ROOMS) {
            for (int j = 0; j < NUMBER_OF_SINGLE_ROOMS; ++j) {
                if (singleRooms[j] == '-') {
                    singleRooms[j] = gender;
                    mtx.unlock();
                    return "Клиент " + std::to_string(clientNumber) + " с гендером " +
                    std::string(1, gender) + " заселился в одноместную комнату под номером " +
                    std::to_string(j+1) + '\n';
                }
            }
            mtx.unlock();
            return "Для клиента " + std::to_string(clientNumber) + " с гендером " +
            std::string(1, gender) + " места в отеле не осталось\n";
        } else {
            mtx.unlock();
            return "Клиент " + std::to_string(clientNumber) + " с гендером " +
            std::string(1, gender) + " заселился в двухместную комнату под номером " +
            std::to_string(i+1) + '\n';
        }
    }
};

void AccommodationOfGuests(Hotel *hotel, int numberOfThread, int seconds, double start) {
    while ((clock() - start)/1000.0 < seconds) {
        if (rand() % 2 == 0) {
            std::cout << "Время " + std::to_string((clock() - start)/1000.0) + "\tCтойка регистрации № " +
            std::to_string(numberOfThread + 1) + "\t\t" + hotel->CheckInAClient('M');
        } else {
            std::cout << "Время " + std::to_string((clock() - start)/1000.0) + "\tCтойка регистрации № " +
            std::to_string(numberOfThread + 1) + "\t\t" + hotel->CheckInAClient('W');
        }
        std::this_thread::sleep_for(std::chrono::milliseconds(rand() % 2000));
    }
}

inline bool isInteger(const std::string & s)
{
    if(s.empty() || ((!isdigit(s[0])) && (s[0] != '-') && (s[0] != '+'))) return false;

    char * p;
    strtol(s.c_str(), &p, 10);

    return (*p == 0);
}

int main(int argc, char *argv[]) {
    setlocale(LC_ALL, "ru");

    if (argc != 3) {
        std::cout << "Неверное количество аргументов, нужно ввести количество потоков и время работы программы в секундах" << std::endl;
        return 1;
    }
    int numberOfThreads;
    int numberOfSeconds;
    if (isInteger(argv[1]) && isInteger(argv[2]) && atoi(argv[1]) > 0 && atoi(argv[2]) > 0) {
        numberOfThreads = atoi(argv[1]);
        numberOfSeconds = atoi(argv[2]);
    } else {
        std::cout << "Оба аргумента должы быть натуральными числами" << std::endl;
        return 1;
    }

    Hotel *hotel = new Hotel();
    std::vector<std::thread *> threads;

    double start = clock();
    for (int i = 0; i < numberOfThreads; ++i) {
        std::thread *th = new std::thread(AccommodationOfGuests, hotel, i, numberOfSeconds, start);
        threads.push_back(th);
    }

    for (int i = 0; i < numberOfThreads; ++i) {
        threads[i]->join();
    }
    free(hotel);
    return 0;
}