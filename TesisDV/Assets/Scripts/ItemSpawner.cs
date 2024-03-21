using System.Collections;
using System.Collections.Generic;
using System.Linq;
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
    [SerializeField] private GameObject _blackboard;
    private Coroutine FadeOutSceneCoroutine;
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
        _blackboard = FindObjectsOfType<GameObject>().Where(x => x.name.Equals("DecalsBlackBoardHouse")).FirstOrDefault();
    }

   
    private void SpawnItems(int currentRound)
    {
        switch(currentRound)
        {
            case 0:
                _tutorialRoundItems.SetActive(true);
                ActiveFadeOutExperiment("_FirstExperimentColumn", 0.366f, 0.6f);
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
                _thirdRoundItems.SetActive(true);
                ActiveFadeOutExperiment("_FirstExperimentColumn", 0f, 0.22f);
                _levelDoors[1].IsLockedToGrays = false; //Puerta del baño al patio.
                _levelDoors[7].IsLockedToGrays = false; //Puerta del baño al living.
                _levelDoors[8].IsLockedToGrays = false; //Puerta entre el baño y el patio
                break;
            case 4:
                _fourthRoundItems.SetActive(true);
                ActiveFadeOutExperiment("_SecondExperimentColumn", 0.23f, 0.65f);
                ActiveFadeOutExperiment("_FourthFifthExperimentRow", 0.33f, 0.54f);
                break;
            case 5:
                _fifthRoundItems.SetActive(true);
                ActiveFadeOutExperiment("_FourthFifthExperimentRow", 0.05f, 0.54f);
                break;
            case 6:
                _sixthRoundItems.SetActive(true);
                break;
        }
    }
    public void ActiveFadeOutExperiment(string param,float duration, float maxValue) 
    {
        if (FadeOutSceneCoroutine != null) StopCoroutine(FadeOutSceneCoroutine);
        FadeOutSceneCoroutine = StartCoroutine(LerpFadeOutEffect(param, duration, maxValue));
    }
    //Referencia 0.6f - Inicio, 0.366f Primer Experimento, 0.25f - Segundo Experimento, 0.0f - Tercer Experimento
    //Referencia SecondExperimentColumn 0.65f - Inicio, 0.23f Cuarto y Quinto Experimento
    //Referencia FourthFifth 0.54f - Inicio, 0.1f Cuarto y Quinto Experimento
    IEnumerator LerpFadeOutEffect(string param, float duration, float maxValue)
    {
        float time = maxValue;

        while (time > 0 && time > duration)
        {
            time -= Time.deltaTime;
            var value = Mathf.Clamp(time, duration, maxValue);

            _blackboard.GetComponent<MeshRenderer>().material.SetFloat(param, value);
            yield return null;
        }
    }
    public void ActivateSecondWaveItems()
    {
        GameVars.Values.BasementDirectionMarkers.SetActive(true);
        GameVars.Values.LevelManager.WorkbenchLight.SetActive(true);
        ActiveFadeOutExperiment("_FirstExperimentColumn", 0.22f, 0.366f);
        _secondRoundItems.SetActive(true);
    }

}
