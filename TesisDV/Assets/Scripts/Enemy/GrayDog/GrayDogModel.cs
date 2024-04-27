using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GrayDogModel : Enemy
{
    IController _myController;

    MiniMap miniMap;
    public event Action onRunning = delegate { };
    private void Awake()
    {
        _fsm = new StateMachine();
        _pf = new Pathfinding();
        HP = 1.5f;
        GameVars.Values.WaveManager.EnhanceEnemyStatsPerWave(this);
        _fsm.AddState(EnemyStatesEnum.SpawningState, new SpawningState(_fsm, this, EnemyStatesEnum.CatState));
    }
    // Start is called before the first frame update
    void Start()
    {
        _myController = new GrayDogController(this, GetComponent<GrayDogView>());
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

        _fsm.ChangeState(EnemyStatesEnum.SpawningState);
    }

    // Update is called once per frame
    void Update()
    {
        if (!isDead)
        {
            _myController.OnUpdate();
        }
    }

    public void Destroy() //Se llama desde la animacion.
    {
        Destroy(gameObject);
    }
}
