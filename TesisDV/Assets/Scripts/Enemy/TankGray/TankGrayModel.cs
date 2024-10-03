using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.AI;

public class TankGrayModel : Enemy
{
    IController _myController;
    MiniMap miniMap;

    private void Awake()
    {
        //_pfManager = GameObject.Find("PathfindingManager").GetComponent<PathfindingManager>();  Probamos usar pathfindingManager como clase estatica.
        _fsm = new StateMachine();
        _pf = new Pathfinding();
        HP = 18f;
        _startSpeed = _movingSpeed;
        PoisonHitted = false;
        SetStatsEnhanced();
        //GameVars.Values.WaveManager.EnhanceEnemyStatsPerWave(this);
        _fsm.AddState(EnemyStatesEnum.SpawningState, new SpawningState(_fsm, this, EnemyStatesEnum.CatState));
        _fsm.AddState(EnemyStatesEnum.CatState, new CatState(_fsm, this, _pf));
        _fsm.AddState(EnemyStatesEnum.ChaseState, new ChaseState(_fsm, this));
        _fsm.AddState(EnemyStatesEnum.AttackPlayerState, new AttackPlayerState(_fsm, this));
        _fsm.AddState(EnemyStatesEnum.ChaseTrapState, new ChaseTrapState(_fsm ,this));
        _fsm.AddState(EnemyStatesEnum.AttackTrapState, new AttackTrapState(_fsm, this));
        _fsm.AddState(EnemyStatesEnum.EscapeState, new EscapeState(_fsm, this, _pf));
        _fsm.AddState(EnemyStatesEnum.ProtectState, new ProtectState(_fsm, this, _pf));
        _fsm.AddState(EnemyStatesEnum.PathfindingState, new PathfindingState(_fsm, this, _pf));
    }

    private void Start()
    {
        _myController = new TankGrayController(this, GetComponent<TankGrayView>());
        _capsuleCollider = GetComponent<CapsuleCollider>();
        _as = GetComponent<AudioSource>();

        AIManager.Instance.SubscribeEnemyForPosition(this);

        _player = GameVars.Values.Player;
        _cat = GameVars.Values.Cat;

        _lm = GameObject.Find("GameManagement").GetComponent<LevelManager>();
        _lm.AddGray(this); 
        miniMap = FindObjectOfType<MiniMap>();
        miniMap.grays.Add(this); 
        miniMap.AddLineRenderer(lineRenderer);

        _fsm.ChangeState(EnemyStatesEnum.SpawningState); //Cambiar estado siempre al final del Start para tener las referencias ya asignadas.

        //ReferenceEvent(true);//Referencia al Onwalk
    }

    void Update()
    {
        if(!isDead)
        {
            _myController.OnUpdate();
        }
    }

    public void BackToPool() //Se llama desde la animacion.
    {
        GameVars.Values.WaveManager.TankGrayPool.ReturnObject(this);
    }
}
