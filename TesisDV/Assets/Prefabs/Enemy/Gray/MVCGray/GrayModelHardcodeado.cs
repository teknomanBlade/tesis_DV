using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.AI;

public class GrayModelHardcodeado : Enemy
{
    IController _myController;
    MiniMap miniMap;

    private void Awake()
    {
        //_pfManager = GameObject.Find("PathfindingManager").GetComponent<PathfindingManager>(); Probamos usar pathfindingManager como clase estatica.
        isAwake = true;
        _fsm = new StateMachine();
        _pf = new Pathfinding();    
       
        _fsm.AddState(EnemyStatesEnum.HardcodeCatState, new HardcodeCatState(_fsm, this));
        _fsm.AddState(EnemyStatesEnum.HardcodeAttackState, new HardcodeAttackState(_fsm, this));
    }

    private void Start()
    {
        _myController = new HardcodeController(this, GetComponent<GrayView>());
        _capsuleCollider = GetComponent<CapsuleCollider>();
        _as = GetComponent<AudioSource>();
        _startSpeed = _movingSpeed;
        AIManager.Instance.SubscribeEnemyForPosition(this);

        _player = GameVars.Values.Player;
        _cat = GameVars.Values.Cat;

        //_navMeshAgent = GetComponent<NavMeshAgent>(); //Se va el navmesh

        _lm = GameObject.Find("GameManagement").GetComponent<LevelManager>();
        _lm.AddGray(this);  //Cambiar a GrayModel
        miniMap = FindObjectOfType<MiniMap>();
        miniMap.grays.Add(this); // Cambiar a GrayModel
        miniMap.AddLineRenderer(lineRenderer);

        _fsm.ChangeState(EnemyStatesEnum.HardcodeCatState); //Cambiar estado siempre al final del Start para tener las referencias ya asignadas.

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
        if(isDead)
        {
            GameVars.Values.Cat.CanMove();
        }
    }
 
    /* public void SetObjective(GameObject targetPosition) No se usa, se usa directamente ResetPathAndSetObjective()
    {
        currentObjective = targetPosition;
    } */
}
