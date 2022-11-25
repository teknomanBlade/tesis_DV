using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ItemSpawner : MonoBehaviour
{
    [SerializeField] private GameObject _tutorialRoundItems;
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
        _tutorialRoundItems = transform.GetChild(0).gameObject;
        _firstRoundItems =  transform.GetChild(1).gameObject;
        _secondRoundItems = transform.GetChild(2).gameObject;
        _thirdRoundItems =  transform.GetChild(3).gameObject;
        _fourthRoundItems = transform.GetChild(4).gameObject;
        _fifthRoundItems = transform.GetChild(5).gameObject;
        _sixthRoundItems = transform.GetChild(6).gameObject;
    }

    private void SpawnItems(int currentRound)
    {
        switch(currentRound)
        {
            case 0:
                _tutorialRoundItems.SetActive(true);
                break;
            case 1:
                _firstRoundItems.SetActive(true);
                break;
            case 2:
                GameVars.Values.ShowNotificationDefinedTime("You can go to the Basement at the Tools Workbench to Buy and Update Traps.", 4.5f, () => ActivateSecondWaveItems());
                _levelDoors[2].IsLockedToGrays = false; //Puerta de la cocina a atras de la casa.
                _levelDoors[3].IsLockedToGrays = false; //Puerta de la cocina a un costado de la casa.
                _levelDoors[5].IsLockedToGrays = false; //Puerta de la cocina al living.
                break;
            case 3:
                    //_secondRoundItems.SetActive(false);
                _thirdRoundItems.SetActive(true);
                _levelDoors[1].IsLockedToGrays = false; //Puerta del baño al patio.
                _levelDoors[7].IsLockedToGrays = false; //Puerta del baño al living.
                _levelDoors[8].IsLockedToGrays = false; //Puerta entre el baño y el patio
            break;
            case 4:
                _fourthRoundItems.SetActive(true);
                break;
            case 5:
                //_firstRoundItems.SetActive(false);
                _fifthRoundItems.SetActive(true);
                break;
            case 6:
                //_secondRoundItems.SetActive(false);
                _sixthRoundItems.SetActive(true);
                break;
        }
    }

    public void ActivateSecondWaveItems()
    {
        GameVars.Values.LevelManager.WorkbenchLight.SetActive(true);
        _secondRoundItems.SetActive(true);
        
    }
}
