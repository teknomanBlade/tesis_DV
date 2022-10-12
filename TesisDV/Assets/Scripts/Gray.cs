//using System.Numerics;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.AI;

//CAMBIO PARA MVC
//No hacemos daño por observer, quito el IPlayerDamageObserver.
public class Gray : MonoBehaviour, IHittableObserver, IDoorGrayInteractObservable
{
    private List<IPlayerDamageObserver> _myObserversPlayerDamage = new List<IPlayerDamageObserver>();
    private List<IDoorGrayInteractObserver> _myObserversDoorGrayInteract = new List<IDoorGrayInteractObserver>();
    [SerializeField]
    private GameObject _player;
    private Player _playerScript;
    [SerializeField]
    private float _movingSpeed;
    private AudioSource _as;
    [SerializeField]
    private Animator _anim;
    private Rigidbody _rb;
    private CapsuleCollider _cc;
    private LevelManager _lm;
    private NavMeshAgent _navMeshAgent;
    private NavMeshPath _navMeshPath;
    private bool _isWalkingSoundPlaying = false;
    [SerializeField]
    private bool _isMoving = true;
    private float _dmg = 50f;
    private bool _hasHitEffectActive = false;
    private float _attackWindup = 1.333f;
    public float distanceToPlayer;
    public float pursueThreshold = 10f;
    public float disengageThreshold = 15f;
    public float attackThreshold = 2.5f;
    public float attackDisengageThreshold = 3f;
    [SerializeField]
    public Vector3[] _waypoints;
    private int _currentWaypoint = 0;
    private int _currentCorner = 0;
    public Coroutine attackCoroutine;
    public Coroutine EMPAttackCoroutine;
    public Coroutine stunCoroutine;
    public Coroutine hitCoroutine;
    public Coroutine currentCoroutine;
    public Coroutine dissolveCoroutine;
    public bool dead = false;
    public bool attacking = false;
    public bool pursue = false;
    public bool stun = false;
    public bool skillEMP = false;
    public bool awake = false;
    private bool _canAttack = true;
    public int hp = 3;
    public bool hasObjective = false;
    private Vector3 _exitPos;
    private Vector3 _currentObjective;
    private Vector3 _doorPos;
    private Vector3 _trapPos;
    public EMPAttack EMPAttack;
    private float nearestDoorDistance = 1000;
    private Transform nearestDoor;
    private Vector3 nearestDoorVector;
    private bool canCreatePath;
    private bool pathIsCreated;
    private bool _foundDoorInPath;
    private bool _foundTrapInPath;
    private BaseballLauncher _currentObstacleTrap;
    private Coroutine _currentCoroutine;
    public delegate void OnGrayAttackDelegate(bool attack);
    public event OnGrayAttackDelegate OnGrayAttackChange;
    /*[SerializeField]
    private Material deathMaterial;*/

    [SerializeField]
    private Material dissolveMaterial;

    [SerializeField]
    private Material sphereEffectMaterial;

    private SkinnedMeshRenderer skinned;
    private float _valueToChange;

    [SerializeField]
    private ParticleSystem _hitEffect;
    [SerializeField]
    private ParticleSystem _deathEffect;
    [SerializeField]
    private GameObject _hitWave;

    private float timePassed = 0;
    [SerializeField]
    private LineRenderer lineRenderer;
    MiniMap miniMap;

    public Transform CatGrabPos;

    private void Awake()
    {
        canCreatePath = false;
        _anim = GetComponent<Animator>();
        _anim.SetBool("IsSpawning", true);
        _rb = GetComponent<Rigidbody>();
        _cc = GetComponent<CapsuleCollider>();
        _as = GetComponent<AudioSource>();
        _player = GameVars.Values.Player.gameObject;
        _playerScript = GameVars.Values.Player;

        //CAMBIO PARA MVC
        //No hacemos daño por observer, quito el IPlayerDamageObserver.
        //AddObserver(_playerScript);

        AddObserverDoorGrayInteract(_playerScript);
        _lm = GameObject.Find("GameManagement").GetComponent<LevelManager>();
        //EMPAttack = GetComponentInChildren<EMPAttack>();


        //CAMBIO PARA MVC
        //El EMPAttack funciona por trigger.

        //EMPAttack.SetOwner(this);
        //_isMoving = true;


        _navMeshAgent = GetComponent<NavMeshAgent>();
        skinned = GetComponentInChildren<SkinnedMeshRenderer>();
        nearestDoorDistance = 1000;

        //CAMBIO PARA MVC
        //Esta lista ahora referencia GrayModel, no Gray.
        //_lm.AddGray(this);


        miniMap = FindObjectOfType<MiniMap>();

        //CAMBIO PARA MVC
        //Esta lista ahora referencia GrayModel, no Gray.
        //miniMap.grays.Add(this);


        miniMap.AddLineRenderer(lineRenderer);
        //Exit pos lo setea el UFO en el instantiate.
        /*  Vector3 aux = _lm.allUfos[0].transform.position;
         _exitPos = new Vector3(aux.x, 0f, aux.z); */
    }

    private void Start()
    {
        //for testing
        //Invoke("Die", 0.5f);
    }

    private void Update()
    {
        if (_player == null)
        {
            StopAllCoroutines();
            awake = false;
        }
        if (awake)
        {
            /*if (skillEMP)
            {
                _anim.SetBool("IsEMP", true);
            }
            else
            {*/
            //_anim.SetBool("IsEMP", false);
            if (!stun)
            {
                distanceToPlayer = Vector3.Distance(_player.transform.position, transform.position);

                if (IsInSight() && !_lm.enemyHasObjective)
                {
                    if (CanAttack())
                    {
                        if (attackCoroutine == null) attackCoroutine = StartCoroutine("Attack");
                    }
                    else
                    {
                        if (attackCoroutine != null)
                        {
                            StopCoroutine(attackCoroutine);
                            attackCoroutine = null;
                            attacking = false;
                        }
                    }
                    pursue = true;

                    if (!_isWalkingSoundPlaying)
                        StartCoroutine(PlayGraySound());

                    //_anim.SetBool("IsWalking", true); Ahora en MovingAnimations()
                }
                else
                {
                    pursue = false;
                    _isWalkingSoundPlaying = false;
                    //_anim.SetBool("IsWalking", false); Ahora en MovingAnimations()
                }

                if (canCreatePath)
                {
                    _navMeshAgent.ResetPath();
                    CalculatePath(_currentObjective);
                    //_currentCorner = 0;
                    canCreatePath = false;
                    pathIsCreated = false;
                }

                if (_isMoving)
                {
                    //ReliableMove();
                    Move();
                }
                MovingAnimations();
                CheckPathStatus();

                if (!_lm.enemyHasObjective && Vector3.Distance(transform.position, _lm.objective.transform.position) < 3f)
                {
                    GrabObjective();
                    GameVars.Values.ShowNotification("The cat has been captured! You must prevent the grays getting to the ship!");
                }
                if (_lm.enemyHasObjective && Vector3.Distance(transform.position, _exitPos) < 3f)
                {
                    GoBackToShip();
                }
                if (hasObjective) MoveObjective();
            }
            else
            {
                pursue = false;
                _isWalkingSoundPlaying = false;
                _isMoving = false;
            }
            //}
        }
    }
    public void EndSpawnAnim()
    {
        _anim.SetBool("IsSpawning", false);
    }
    public void Move()
    {
        Vector3 dest = default(Vector3);
        if (_foundDoorInPath)
        {
            _currentObjective = _doorPos;
            canCreatePath = true;

            MoveTo();
            //Poner en falso al final.
        }
        else if (_foundTrapInPath)
        {
            _currentObjective = _trapPos;
            canCreatePath = true;
            BreakTrap(_currentObstacleTrap);
            MoveTo();
            //Poner en falso al final.
        }
        else if (pursue)
        {
            //CalculatePath(_player.transform.position);
            _currentObjective = _player.transform.position;
            canCreatePath = true;

            MoveTo();
            //dest = _player.transform.position;
        }
        else if (_lm.enemyHasObjective)
        {
            //CalculatePath(_exitPos);
            _currentObjective = _exitPos;
            canCreatePath = true;

            MoveTo();
            //dest = _exitPos;
        }
        //else if (_lm.allDoorsAreClosed)
        //{
        /*StartCoroutine(FindClosestDoor());

        dest = nearestDoor.position;
        if (Vector3.Distance(transform.position, nearestDoorVector) < 3f)
        {
            //_anim.SetBool("IsAttacking", true);
            currentCoroutine = StartCoroutine(PlayAnimation("IsAttacking", "Attack"));
            nearestDoor.GetComponent<AuxDoor>().Interact();
            GameVars.Values.ShowNotification("The Grays have entered through the " + GetDoorAccessName(nearestDoor.GetComponent<AuxDoor>().myDoor.itemName));
            TriggerDoorGrayInteract("GrayDoorInteract");
            StartCoroutine(LerpOutlineWidthAndColor(8f,2f, Color.red));
            _lm.ChangeDoorsStatus();
        } COMENTAR HASTA SOLUCIONAR EL TEMA DE LAS PUERTAS*/

        //}
        else
        {
            //CalculatePath(_lm.objective.transform.position);
            _currentObjective = _lm.objective.transform.position;
            canCreatePath = true;

            MoveTo();
            //dest = _lm.objective.transform.position;
        }

        var dir = dest - transform.position;
        dir.y = 0f;

        //_navMeshAgent.destination = dest;
    }

    IEnumerator PlayAnimation(string param, string name, Action action = null)
    {
        _anim.SetBool(param, true);
        var clips = _anim.runtimeAnimatorController.animationClips;
        float time = clips.First(x => x.name == name).length;
        yield return new WaitForSeconds(time);
        if (action != null) action.Invoke();
        _navMeshAgent.speed = 1;
        _anim.SetBool(param, false);
    }

    public void MovingAnimations()
    {
        if (_isMoving)
        {
            _anim.SetBool("IsWalking", true);
        }
        else
            _anim.SetBool("IsWalking", false);
    }

    public string GetDoorAccessName(string name)
    {
        var result = "";
        if (name.Contains("Red"))
        {
            result = "Red Access Door.";
        }
        else if (name.Contains("Black"))
        {
            result = "Black Access Door.";
        }
        else if (name.Contains("White"))
        {
            result = "White Access Door.";
        }
        return result;
    }

    public void CheckPathStatus()
    {
        if (_navMeshAgent.pathStatus == NavMeshPathStatus.PathPartial || _navMeshAgent.pathStatus == NavMeshPathStatus.PathInvalid)
        {
            //_isMoving = false;

        }
        else
        {
            //_isMoving = true;
        }
    }

    public IEnumerator PlayGraySound()
    {
        GameVars.Values.soundManager.PlaySoundOnce(_as, "VoiceWhispering", 0.4f, true);
        yield return new WaitForSeconds(.01f);
        _isWalkingSoundPlaying = true;
    }

    /*public IEnumerator PlayGrayDeathSound()
    {
         _anim.SetBool("IsDead", true);
        SwitchDissolveMaterial(dissolveMaterial);
        GameVars.Values.soundManager.PlaySoundOnce(_as, "GrayDeathSound", 0.4f, true);
        yield return new WaitForSeconds(1.6f);
        GameVars.Values.soundManager.StopSound();
        yield return new WaitForSeconds(2.5f);
        
        //StopCoroutine(_currentCoroutine);
        //yield return StartCoroutine(LerpScaleDissolve(0f, 1.5f)); 
        //Dead();
    }*/


    private bool IsInSight()
    {
        LayerMask layermask = 1 << 12;
        layermask = layermask << 3;
        if (Physics.Raycast(transform.position, _player.transform.position, disengageThreshold, layermask))
        {
            return false;
        }
        if (pursue)
        {
            if (distanceToPlayer > disengageThreshold) return false;
        }
        else
        {
            if (distanceToPlayer > pursueThreshold) return false;
        }
        return true;
    }

    private bool CanAttack()
    {
        if (!IsInSight()) return false;
        if (attacking)
        {
            if (distanceToPlayer > attackDisengageThreshold) return false;
        }
        else
        {
            if (distanceToPlayer > attackThreshold) return false;
        }
        return true;
    }
    public void SwitchDissolveMaterial(Material material)
    {
        var materials = skinned.sharedMaterials.ToList();
        materials.Clear();
        materials.Add(material);
        skinned.sharedMaterials = materials.ToArray();
    }

    IEnumerator Attack()
    {

        //Verifica el booleano antes de atacar, este booleano se desactiva en Die y Stun. Se vuelve a activar al final del Stun.
        attacking = true;
        _isMoving = false;
        _navMeshAgent.speed = 0;
        StartCoroutine(PlayAnimation("IsAttacking", "Attack"));
        yield return null;
        //_anim.SetBool("IsAttacking", true);


        //yield return new WaitForSeconds(_attackWindup);
        //if(_canAttack)
        //{
        //TriggerPlayerDamage("DamagePlayer");
        //PlayParticleSystemShader();
        //attacking = false;
        //_isMoving = true;

        //}

        //attackCoroutine = StartCoroutine("Attack");
        //_anim.SetBool("IsAttacking", false);


    }

    private void AttackPlayer()
    {
        //TriggerPlayerDamage("DamagePlayer");
        OnGrayAttackChange?.Invoke(attacking);
        attacking = false;
        _isMoving = true;
    }

    public void PlayDeathParticleEffect()
    {
        _deathEffect.gameObject.SetActive(true);
        _deathEffect.Play();
    }

    public void Stun(float time)
    {
        _navMeshAgent.speed = 0;
        stun = true;
        stunCoroutine = StartCoroutine(PlayAnimation("IsStunned", "Stun", () => { UnStun(); }));
    }

    public void SecondStun(float time)
    {
        _navMeshAgent.speed = 0;
        _canAttack = false;
        stun = true;
        _isMoving = false;
        _navMeshAgent.destination = transform.position;
        if (hasObjective)
        {
            DropObjective();
        }
        stunCoroutine = StartCoroutine(PlayAnimation("IsStunned", "Stun", () => { UnStun(); }));
        _rb.isKinematic = true;
        //Invoke("SecondUnStun", time);
    }

    private void MoveTo()
    {
        if (pathIsCreated)
        {
            Vector3 dir = _waypoints[_currentWaypoint] - transform.position;
            transform.forward = dir;
            transform.position += transform.forward * _movingSpeed * Time.deltaTime;

            if (dir.magnitude < 0.5f)
            {
                //_currentWaypoint++; Lo sumamos después de verificar.
                if (_currentWaypoint + 1 > _waypoints.Length) //-1
                {
                    _currentWaypoint = 0;
                    canCreatePath = true;
                }
                else
                {
                    _currentWaypoint++;
                }
            }
        }

        /* if (_currentCorner < _navMeshAgent.path.corners.Length)
            {
                Vector3 dir = _navMeshAgent.path.corners[_currentCorner] - transform.position;
                transform.forward = dir;
                transform.position += transform.forward * _movingSpeed * Time.deltaTime;
            }

        if (Vector3.Distance(transform.position, _navMeshAgent.path.corners[_currentCorner]) <= .1f)  //dir.magnitude < 0.1f
        {
            if(_currentCorner + 1 > _navMeshAgent.path.corners.Length)
            {
                canCreatePath = true;
                _currentCorner = 0;
            }
            else
            {
                Mathf.Clamp(_currentCorner, 0 , _navMeshAgent.path.corners.Length);
                _currentCorner++;
                Mathf.Clamp(_currentCorner, 0 , _navMeshAgent.path.corners.Length);
            }
        } PROBANDO OTRO METODO USANDO FOR PARA REUNIR LOS PUNTOS EN UNA LISTA DE WAYPOINTS*/
    }

    public void UnStun()
    {
        _rb.isKinematic = false;
        stun = false;
        _isMoving = true;
        attacking = false;
        _canAttack = false;
    }

    public void SecondUnStun()
    {

        Vector3 dest = default(Vector3);
        if (pursue) dest = _player.transform.position;
        else if (_lm.enemyHasObjective) dest = _exitPos;
        else dest = _lm.objective.transform.position;
        _rb.isKinematic = false;
        stun = false;
        _isMoving = false;
        _canAttack = true;
    }

    public void SetPos(Vector3 pos)
    {
        transform.position = pos;
    }

    public void AwakeGray()
    {
        awake = true;
    }

    public void Damage()
    {
        Stun(0.2f);
        hp--;
        if (hp <= 0) Die();
    }

    public void GrabObjective()
    {
        hasObjective = true;
        _anim.SetBool("IsGrab", true);
        GameVars.Values.TakeCat(_exitPos);
        //_lm.CheckForObjective();
    }

    public void MoveObjective()
    {
        //CAMBIAR PARA QUE EL GATO QUEDE ENTRE LAS MANOS.
        //if (_lm.objective != null) _lm.objective.transform.position = transform.position + new Vector3(0f, 1.8f - 0.35f, -0.87f);
        if (_lm.objective != null) _lm.objective.transform.position = CatGrabPos.transform.position;

    }

    public void DropObjective()
    {
        hasObjective = false;
        GameVars.Values.SetCatFree();
        //_lm.CheckForObjective();
    }

    public void GoBackToShip()
    {
        if (hasObjective)
        {
            _lm.LoseGame();
            Destroy(_lm.objective);
        }

        //CAMBIO PARA MVC
        //Esta lista ahora referencia GrayModel, no Gray.
        //_lm.RemoveGray(this);
        //miniMap.RemoveGray(this);


        //_lm.EnemyCameBack();
        Destroy(gameObject);
    }

    public void FoundDoorInPath(Door door)
    {
        _doorPos = door.gameObject.transform.position;
        _foundDoorInPath = true;
        attacking = true;
        _isMoving = false;
        _navMeshAgent.speed = 0;
        StartCoroutine(PlayAnimation("IsAttacking", "Attack"));
        OpenDoor(door);
    }

    private void OpenDoor(Door door)
    {
        door.Interact();
        GameVars.Values.ShowNotification("The Grays have entered through the " + GetDoorAccessName(door.itemName));
        TriggerDoorGrayInteract("GrayDoorInteract");
        //StartCoroutine(LerpOutlineWidthAndColor(8f,2f, Color.red));
        _foundDoorInPath = false;
        attacking = false;
    }

    public void FoundTrapInPath(GameObject trap) //Después cambiar cuando haya un script Trap.
    {
        _trapPos = trap.transform.position;
        _currentObstacleTrap = trap.GetComponent<BaseballLauncher>();
        _foundTrapInPath = true;
    }

    private void BreakTrap(BaseballLauncher trap)
    {
        //Si la distancia a la trampa es menor que tanto ataca, espera unos segundos y vuelve a atacar hasta destruir la trampa. Ahi pone en falso el Foundtrap.
        Vector3 dir = _trapPos - transform.position;
        if (dir.magnitude < 2.5f)
        {
            _navMeshAgent.speed = 0;
            float timeToAttack = 5f;
            float timePassed = 0f;

            if (timePassed > 0)
            {
                timePassed -= Time.deltaTime;
            }
            else if (timePassed <= 0 && trap) //Después cambiar cuando haya un script Trap.
            {
                attacking = true;
                _isMoving = false;
                EMPAttackCoroutine = StartCoroutine(PlayAnimation("IsEMP", "EMPSkill", () => { trap.TakeDamage(_dmg); }));
                timePassed = timeToAttack;
                attacking = false;
                _isMoving = true;
                _foundTrapInPath = false;
            }
        }
    }
    public void PlaySoundEMP()
    {
        GameVars.Values.soundManager.PlaySoundOnce(_as, "EMP_SFX", 0.35f, false);
    }
    IEnumerator PlayAnimationsDeathPostDeath(string param, string name)
    {
        _anim.SetBool(param, true);
        _anim.speed = 1f;
        var clips = _anim.runtimeAnimatorController.animationClips;
        float time = clips.First(x => x.name == name).length;
        yield return new WaitForSeconds(time);
        _anim.SetBool(param, false);
    }
    public void Die()
    {
        dead = true;
        _canAttack = false;
        //var spawnPos = new Vector3(transform.position.x, transform.position.y + 8f, transform.position.z);
        //var UFO = GameVars.Values.LevelManager.UFOsPool.GetObject().InitializePosition(spawnPos);
        GameVars.Values.soundManager.PlaySoundOnce(_as, "GrayDeathSound", 0.4f, true);
        GetComponent<CapsuleCollider>().enabled = false;
        StartCoroutine(PlayAnimationsDeathPostDeath("IsDead", "Death"));
        _navMeshAgent.destination = transform.position;
        if (hasObjective)
        {
            DropObjective();
        }
        awake = false;
        _rb.isKinematic = true;
        _cc.enabled = false;

        //CAMBIO PARA MVC
        //Esta lista ahora referencia GrayModel, no Gray.
        //_lm.RemoveGray(this);

        //_lm.CheckForObjective();
    }
    public void Dissolve()
    {
        _currentCoroutine = StartCoroutine(PlayShaderDissolve());
    }
    IEnumerator PlayShaderDissolve()
    {
        _deathEffect.Stop();
        SwitchDissolveMaterial(dissolveMaterial);
        dissolveCoroutine = StartCoroutine(LerpScaleDissolve(0f, 1f));
        yield return new WaitForSeconds(1.5f);
        Dead();
    }

    public void PlayPostDeath()
    {
        _anim.SetBool("IsPostDeath", true);
    }

    public void Dead()
    {
        //dissolveMaterial.SetFloat("_ScaleDissolveGray", 1);

        //CAMBIO PARA MVC
        //Esta lista ahora referencia GrayModel, no Gray.
        //miniMap.RemoveGray(this);


        Destroy(gameObject);
    }

    public Vector3 GetVelocity()
    {
        return _navMeshAgent.velocity;
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(transform.position, attackThreshold);
        Gizmos.DrawWireSphere(transform.position, attackDisengageThreshold);
        Gizmos.color = Color.white;
        Gizmos.DrawWireSphere(transform.position, pursueThreshold);
        Gizmos.DrawWireSphere(transform.position, disengageThreshold);
        Gizmos.DrawRay(transform.position, _player.transform.position - transform.position);
    }

    public void OnNotify(string message)
    {
        if (message.Equals("TennisBallHit"))
        {
            //_anim.SetBool("IsHitted", true);
            hitCoroutine = StartCoroutine(PlayAnimation("IsHitted", "Hit"));
            ActiveInnerEffect();
            GameVars.Values.soundManager.PlaySoundAtPoint("BallHit", transform.position, 0.45f);
            Damage();
            Stun(5f);
        }
        else if (message.Equals("RacketHit"))
        {
            if (_anim)
            {
                hitCoroutine = StartCoroutine(PlayAnimation("IsHitted", "Hit"));
                ActiveInnerEffect();
                GameVars.Values.soundManager.PlaySoundAtPoint("BallHit", transform.position, 0.45f);
                Damage();
                Stun(5f);
            }
        }
    }
    public void RacketHit(bool hit)
    {
        if (hit)
        {
            currentCoroutine = StartCoroutine(PlayAnimation("IsHitted", "Hit"));
            Stun(5f);
            ActiveInnerEffect();
            GameVars.Values.soundManager.PlaySoundAtPoint("BallHit", transform.position, 0.45f);
            Damage();
        }
    }
    public void ActiveInnerEffect()
    {
        _hitEffect.Play();
        _hasHitEffectActive = true;
        _hitWave.SetActive(!_hitWave.activeSelf);
        _hitWave.GetComponent<Animator>().SetBool("IsHit", true);
    }

    IEnumerator FindClosestDoor()
    {
        nearestDoorDistance = 1000f;

        foreach (Transform door in _lm.allDoors)
        {
            if (Vector3.Distance(transform.position, door.position) < nearestDoorDistance)
            {
                nearestDoorDistance = Vector3.Distance(transform.position, door.position);
                nearestDoor = door;
                nearestDoorVector = door.position;

            }

        }
        yield return new WaitForSeconds(0.5f);
    }

    IEnumerator LerpScaleDissolve(float endValue, float duration)
    {
        float time = 0;
        float startValue = _valueToChange;

        while (time < duration)
        {
            _valueToChange = Mathf.Lerp(startValue, endValue, time / duration);
            time += Time.deltaTime;

            skinned.material.SetFloat("_ScaleDissolveGray", _valueToChange);
            yield return null;
        }

        _valueToChange = endValue;
    }
    IEnumerator LerpOutlineWidthAndColor(float endValue, float duration, Color color)
    {
        float time = 0;
        float startValue = _valueToChange;

        while (time < duration)
        {
            _valueToChange = Mathf.Lerp(startValue, endValue, time / duration);
            time += Time.deltaTime;

            nearestDoor.GetComponent<AuxDoor>().myDoor.GetComponent<Outline>().OutlineColor = color;
            nearestDoor.GetComponent<AuxDoor>().myDoor.GetComponent<Outline>().OutlineWidth = _valueToChange;
            yield return null;
        }

        _valueToChange = endValue;
        yield return StartCoroutine(LerpOutlineWidthAndColor(0f, 2f, Color.red));
        yield return new WaitForSeconds(0.5f);
        yield return StartCoroutine(LerpOutlineWidthAndColor(0f, 2f, Color.green));
    }
    public Gray SetExitUFO(Vector3 exitPosition)
    {
        Vector3 aux = exitPosition;
        _exitPos = new Vector3(aux.x, 0f, aux.z);

        return this;
    }

    private void CalculatePath(Vector3 targetPosition)
    {
        //_waypoints = new List<Vector3>();
        //_waypoints = null;


        _navMeshAgent.ResetPath();
        NavMeshPath path = new NavMeshPath();
        //_navMeshAgent.CalculatePath(targetPosition, path);
        if (NavMesh.CalculatePath(transform.position, _currentObjective, NavMesh.AllAreas, path))
        {
            _navMeshAgent.SetPath(path);

            for (int i = 0; i > _navMeshAgent.path.corners.Length; i++)
            {
                _waypoints[i] = _navMeshAgent.path.corners[i];
            }
            pathIsCreated = true;
            DrawLineRenderer(path.corners);
        }

        //NavMesh.CalculatePath(transform.position, targetPosition, NavMesh.AllAreas, _navMeshPath)
    }

    public void AddObserver(IPlayerDamageObserver obs)
    {
        _myObserversPlayerDamage.Add(obs);
    }

    public void RemoveObserver(IPlayerDamageObserver obs)
    {
        if (_myObserversPlayerDamage.Contains(obs)) _myObserversPlayerDamage.Remove(obs);
    }

    //CAMBIO PARA MVC
        //No usamos observer para daño, todo pasa por el triggerCollider del ataque en cuestion.
    //public void TriggerPlayerDamage(string triggerMessage)
    //{
    //    _myObserversPlayerDamage.ForEach(x => x.OnNotifyPlayerDamage(triggerMessage));
    //}

    public void AddObserverDoorGrayInteract(IDoorGrayInteractObserver obs)
    {
        _myObserversDoorGrayInteract.Add(obs);
    }

    public void RemoveObserverDoorGrayInteract(IDoorGrayInteractObserver obs)
    {
        if (_myObserversDoorGrayInteract.Contains(obs)) _myObserversDoorGrayInteract.Remove(obs);
    }

    public void TriggerDoorGrayInteract(string triggerMessage)
    {
        _myObserversDoorGrayInteract.ForEach(x => x.OnNotifyDoorGrayInteract(triggerMessage));
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
}
