using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.AI;

public class TallGrayModel : Enemy
{
    IController _myController;
    
    MiniMap miniMap;

    private void Awake()
    {
        _pfManager = GameObject.Find("PathfindingManager").GetComponent<PathfindingManager>();
        _fsm = new StateMachine();
        _pf = new Pathfinding();
        
        _fsm.AddState(EnemyStatesEnum.PlayerState, new PlayerState(_fsm, this, _pf));
        _fsm.AddState(EnemyStatesEnum.TallGrayAttackState, new TallGrayAttackState(_fsm, this));
        _fsm.AddState(EnemyStatesEnum.PathfindingState, new PathfindingState(_fsm, this, _pf));
    }

    private void Start()
    {
        _myController = new TallGrayController(this, GetComponent<TallGrayView>());
        _capsuleCollider = GetComponent<CapsuleCollider>();
        _as = GetComponent<AudioSource>();

        AIManager.Instance.SubscribeEnemyForPosition(this);

        _player = GameVars.Values.Player;
        _cat = GameVars.Values.Cat;

        //_navMeshAgent = GetComponent<NavMeshAgent>(); //Se va el navmesh

        _lm = GameObject.Find("GameManagement").GetComponent<LevelManager>();
        _lm.AddGray(this);  //Cambiar a GrayModel
        miniMap = FindObjectOfType<MiniMap>();
        miniMap.grays.Add(this); // Cambiar a GrayModel
        miniMap.AddLineRenderer(lineRenderer);

        _fsm.ChangeState(EnemyStatesEnum.PlayerState); //Cambiar estado siempre al final del Start para tener las referencias ya asignadas.

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

    public void Destroy() //Se llama desde la animacion.
    {
        Destroy(gameObject);
    }

}
