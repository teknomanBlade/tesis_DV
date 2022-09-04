using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.AI;

public class GrayModel : MonoBehaviour
{
    [SerializeField] private int _hp;
    [SerializeField] private float _movingSpeed;
    public bool hasObjective;
    private bool pathIsCreated;
    private bool canCreatePath;
    private bool isAwake = false;
    [SerializeField] private bool isAttacking = false;
    public bool isDead = false;

    public StateMachine _fsm;

    IController _myController;

    public Player _player { get; private set; }
    public Cat _cat { get; private set; }

    private NavMeshAgent _navMeshAgent;
    private NavMeshPath _navMeshPath;

    public float pursueThreshold = 10f;
    public float disengageThreshold = 15f;
    public float attackThreshold = 2.5f;
    public float attackDisengageThreshold = 3f;

    [SerializeField]
    public Vector3[] _waypoints;
    private int _currentWaypoint = 0;
    private int _currentCorner = 0;

    public LevelManager _lm { get; private set; }
    [SerializeField]
    private LineRenderer lineRenderer;
    MiniMap miniMap;

    public Vector3 _exitPos;
    public Vector3 trapPos;

    private AudioSource _as;

    [SerializeField] private Transform CatGrabPos;
    private GameObject currentObjective;
    private BaseballLauncher currentObstacleTrap;
    public bool foundTrapInPath = false;

    #region Events

    public event Action<bool> onWalk = delegate { };
    public event Action<bool> onCatGrab = delegate { };
    public event Action onDeath = delegate { };
    public event Action onHit = delegate { };
    public event Action<bool> onAttack = delegate { };
    public event Action onDisolve = delegate { };

    #endregion Events

    private void Awake()
    {
        _fsm = new StateMachine();
        _fsm.AddState(EnemyStatesEnum.CatState, new CatState(_fsm, this));
        _fsm.AddState(EnemyStatesEnum.ChaseState, new ChaseState(_fsm, this));
        _fsm.AddState(EnemyStatesEnum.AttackPlayerState, new AttackPlayerState(_fsm, this));
        _fsm.AddState(EnemyStatesEnum.AttackTrapState, new AttackTrapState(_fsm, this));
        _fsm.AddState(EnemyStatesEnum.EscapeState, new EscapeState(_fsm, this));
        //_fsm.ChangeState(EnemyStatesEnum.CatState);
    }

    private void Start()
    {
        _myController = new GrayController(this, GetComponent<GrayView>());

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
        onWalk(true);
    }

    void Update()
    {
        //_fsm.OnUpdate();
        if(isAwake)
        {
            _myController.OnUpdate();
            ResetPathAndSetObjective(); //Horrible resetear en Update, pero con el pathfinding no va a hacer falta.
        }
        

        /* if(Input.GetKeyDown(KeyCode.L))
        {
            ResetPathAndSetObjective();     PARA TESTEO.
        } */
    }

    public void SetObjective(GameObject targetPosition)
    {
        currentObjective = targetPosition;
    }

    public void ResetPathAndSetObjective()//Vector3 targetPosition)
    {
        _navMeshAgent.ResetPath();
        //CalculatePath(targetPosition);  
        CalculatePath(currentObjective.transform.position);
        _currentWaypoint = 0;
        pathIsCreated = false;
    }

    private void CalculatePath(Vector3 targetPosition)
    {
        _navMeshAgent.ResetPath();
        NavMeshPath path = new NavMeshPath();
        if (NavMesh.CalculatePath(transform.position, targetPosition, NavMesh.AllAreas, path))
        {
            _navMeshAgent.SetPath(path);

            for (int i = 0; i > _navMeshAgent.path.corners.Length; i++)
            {
                _waypoints[i] = _navMeshAgent.path.corners[i];
            }
            pathIsCreated = true;
            DrawLineRenderer(path.corners);  
        }
    }

    public void Move()
    {
        if (pathIsCreated) //Probar sin bool. No funciona, entra a Move cuando el waypoint todavia no tiene valor asignado.
        {
            onWalk(true); //Esta llamada de evento no funciona por el NavMeshAgent.
            Vector3 dir = _waypoints[_currentWaypoint] - transform.position;
            transform.forward = dir;
            transform.position += transform.forward * _movingSpeed * Time.deltaTime;
            Debug.Log(dir.magnitude);
            if (dir.magnitude < 0.5f)
            {
                //_currentWaypoint++; Lo sumamos despu�s de verificar.
                if (_currentWaypoint + 1 > _waypoints.Length) //-1
                {
                    //canCreatePath = true; probar con ResetAndSet directo.
                    ResetPathAndSetObjective();
                    //Debug.Log("Reseted");
                    
                        
                    
                    //_currentWaypoint = 0; Reseteamos el current waypoint en la funcion de arriba ^_^                   
                }
                else
                {
                    _currentWaypoint++;
                }

            }
            
        }
    }

    public void GetDoor(Door door)
    {
        OpenDoor(door);
    }

    public void GrabCat()
    {
        //_anim.SetBool("IsGrab", true); Ahora se usa el evento de abajo.
        onCatGrab(true);
        GameVars.Values.TakeCat(_exitPos); //Ver que corno es esto
        hasObjective = true;
        _lm.CheckForObjective();
    }

    public void GoBackToShip()
    {
        if (hasObjective)
        {
            _lm.LoseGame();
            Destroy(_lm.objective);
        }
        //_lm.RemoveGray(this);
        //miniMap.RemoveGray(this);

        Destroy(gameObject);
    }
    
    public void TakeDamage(int DamageAmount)
    {
        _hp -= DamageAmount;
        GameVars.Values.soundManager.PlaySoundAtPoint("BallHit", transform.position, 0.45f);
        
        if(_hp > 0)
        {
            onHit();
        }
        else
        {
            isDead = true;
            GameVars.Values.soundManager.PlaySoundOnce(_as, "GrayDeathSound", 0.4f, true);
            onDeath();
            //Desabilitar colliders y lo que haga falta.
        }
    }

    public void AttackPlayer() //Verifica que no estemos atacando para mirar hacia el jugador y envia nuevamente la animacion de ataque. El booleano se resetea con un AnimEvent.
    {
        if(!isAttacking)
        {
            var dir = _player.transform.position - transform.position;
            transform.forward = dir;
            onWalk(isAttacking);
            onAttack(!isAttacking);
            isAttacking = true; 
        }
       
    }

    public void AttackTrap()
    {
        //hacer animación de EMPAttack y asignarle daño al trigger del EMPAttackGO.
    }

    public void FoundTrapInPath(GameObject trap)
    {
        trapPos = trap.transform.position;
        currentObstacleTrap = trap.GetComponent<BaseballLauncher>();
        foundTrapInPath = true;
    }

    public void RevertAttackBool() //Esto se llama por la animación de ataque.
    {
        onAttack(!isAttacking);
        onWalk(isAttacking);
        isAttacking = false;   
    }

    private void OpenDoor(Door door)
    {
        door.Interact();
        //Refeencia a View donde hace un play de la animacion de abrir la puerta.

        //GameVars.Values.ShowNotification("The Grays have entered through the " + GetDoorAccessName(door.itemName));
        //TriggerDoorGrayInteract("GrayDoorInteract");
    }

    public void Dissolve()
    {
        onDisolve();
    }

    public Vector3 GetVelocity()
    {
        return _navMeshAgent.velocity;
    }

    private void DrawLineRenderer(Vector3[] waypoints)
    {
        lineRenderer.positionCount = waypoints.Length;
        lineRenderer.SetPosition(0, waypoints[0]);

        for (int i = 1; i < waypoints.Length; i++)
        {
            Vector3 pointPosition = new Vector3(waypoints[i].x, waypoints[i].y, waypoints[i].z);
            lineRenderer.SetPosition(i, pointPosition);
        }
    }

    public void SetPos(Vector3 pos)
    {
        transform.position = pos;
    }

    public void AwakeGray()
    {
        isAwake = true;
    }

    public GrayModel SetExitUFO(Vector3 exitPosition)
    {
        Vector3 aux = exitPosition;
        _exitPos = new Vector3(aux.x, 0f, aux.z);

        return this;
    }
}
