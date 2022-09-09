using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.AI;

public class TallGrayModel : Enemy
{
    public StateMachine _fsm;
    IController _myController;

    MiniMap miniMap;

    private void Awake()
    {
        _fsm = new StateMachine();
        _fsm.AddState(EnemyStatesEnum.CatState, new CatState(_fsm, this));
        _fsm.AddState(EnemyStatesEnum.ChaseState, new ChaseState(_fsm, this));
        _fsm.AddState(EnemyStatesEnum.AttackPlayerState, new AttackPlayerState(_fsm, this));
        _fsm.AddState(EnemyStatesEnum.ChaseTrapState, new ChaseTrapState(_fsm ,this));
        _fsm.AddState(EnemyStatesEnum.AttackTrapState, new AttackTrapState(_fsm, this));
        _fsm.AddState(EnemyStatesEnum.EscapeState, new EscapeState(_fsm, this));
        //_fsm.ChangeState(EnemyStatesEnum.CatState);
    }

    private void Start()
    {
        _myController = new TallGrayController(this, GetComponent<TallGrayView>());

        _as = GetComponent<AudioSource>();

        _player = GameVars.Values.Player;
        _cat = GameVars.Values.Cat;

        _navMeshAgent = GetComponent<NavMeshAgent>();

        _lm = GameObject.Find("GameManagement").GetComponent<LevelManager>();
        _lm.AddGray(this);  //Cambiar a GrayModel
        miniMap = FindObjectOfType<MiniMap>();
        miniMap.grays.Add(this); // Cambiar a GrayModel
        miniMap.AddLineRenderer(lineRenderer);

        _fsm.ChangeState(EnemyStatesEnum.CatState); //Cambiar estado siempre al final del Start para tener las referencias ya asignadas.

        ReferenceEvent(true);//Referencia al Onwalk
    }

    void Update()
    {
        //_fsm.OnUpdate();
        if(isAwake)
        {
            _myController.OnUpdate();
            
            //ResetPathAndSetObjective(); //Horrible resetear en Update, pero con el pathfinding no va a hacer falta. Se resetea en los States ahora.
        }
    }

    /* public void SetObjective(GameObject targetPosition) No se usa, se usa directamente ResetPathAndSetObjective()
    {
        currentObjective = targetPosition;
    } */

    public void GetDoor(Door door)
    {
        OpenDoor(door);
    }

    //Le pide el UFO mas cerca al LevelManager y luego cambia el valor de _exitPos.
    private void GetNearestUFO() //Hasta solucionarlo no se usa. Probar corrutina.
    {
        float currentDistance = 99999;

        foreach (UFO ufo in _lm.AllUFOs)
        {
            if(Vector3.Distance(transform.position, ufo.transform.position) < currentDistance)
            {
                currentDistance = Vector3.Distance(transform.position, ufo.transform.position);
            } 
        }
    }

    private void OpenDoor(Door door)
    {
        door.Interact();
        //Refeencia a View donde hace un play de la animacion de abrir la puerta.

        //GameVars.Values.ShowNotification("The Grays have entered through the " + GetDoorAccessName(door.itemName));
        //TriggerDoorGrayInteract("GrayDoorInteract");
    }

}
