using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ItemSpawner : MonoBehaviour
{
    [SerializeField] private GameObject _firstRoundItems;
    [SerializeField] private GameObject _secondRoundItems;
    [SerializeField] private GameObject _thirdRoundItems;
    [SerializeField] private GameObject _fourthRoundItems;
    [SerializeField] private GameObject _fifthRoundItems;
    [SerializeField] private GameObject _sixthRoundItems;

    [SerializeField] private List<Door> _levelDoors = new List<Door>();   //Despues obtendrán las puertas de otra forma, pero para el dia de hoy sirve.

    void Start()
    {
        GameVars.Values.WaveManager.OnRoundEnd += SpawnItems;
        _firstRoundItems =  transform.GetChild(0).gameObject;
        _secondRoundItems = transform.GetChild(1).gameObject;
        _thirdRoundItems =  transform.GetChild(2).gameObject;
        _fourthRoundItems = transform.GetChild(3).gameObject;
        _fifthRoundItems = transform.GetChild(4).gameObject;
        _sixthRoundItems = transform.GetChild(5).gameObject;
    }

    private void SpawnItems(int currentRound)
    {
        switch(currentRound)
        {
            case 0:
                _firstRoundItems.SetActive(true);
            break;
            case 1:
                    //_firstRoundItems.SetActive(false);
                _secondRoundItems.SetActive(true);
            break;
            case 2:
                    //_secondRoundItems.SetActive(false);
                _thirdRoundItems.SetActive(true);
            break;
            case 3:
                _fourthRoundItems.SetActive(true);
                break;
            case 4:
                //_firstRoundItems.SetActive(false);
                _fifthRoundItems.SetActive(true);
                break;
            case 5:
                //_secondRoundItems.SetActive(false);
                _sixthRoundItems.SetActive(true);
                break;
        }
    }
}
